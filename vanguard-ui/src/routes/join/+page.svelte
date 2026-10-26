<script lang="ts">
	import { resolve } from '$app/paths';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { isAddress, parseEther } from 'ethers';
	import {
		ArrowRight,
		CalendarDays,
		Check,
		Clock,
		ExternalLink,
		GraduationCap,
		RefreshCw,
		Smartphone,
		Sparkles,
		Users,
	} from 'lucide-svelte';
	import { wallet, shortAddress } from '$lib/contracts/provider.svelte';
	import { getArmyRegistry } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import {
		formatToken,
		loadEthBalance,
		loadMember,
		loadUnit,
		sameAddress,
		type ChainMember,
		type ChainUnit,
	} from '$lib/contracts/chain';
	import { cohortPhase, currentWeek, formatCohortDates, getCohort, inviteLink } from '$lib/academy/cohorts';
	import { student } from '$lib/academy/student.svelte';
	import { isDemo } from '$lib/demo/flag';
	import { demoFaucet } from '$lib/demo/mock-chain';
	import { RANK_META } from '$lib/types';
	import RankInsignia from '$components/RankInsignia.svelte';
	import TxNotice from '$components/academy/TxNotice.svelte';
	import CopyField from '$components/academy/CopyField.svelte';

	// Enough test ETH for enlisting plus a few submissions.
	const MIN_FEE_BALANCE = parseEther('0.0002');
	const FAUCETS = [
		{ label: 'Base faucet', href: 'https://faucet.base.org' },
		{ label: 'Alchemy faucet', href: 'https://faucet.alchemy.com' },
		{ label: 'QuickNode faucet', href: 'https://faucet.quicknode.com/base/sepolia' },
	];

	let params = $derived($page.url.searchParams);
	let cohort = $derived(getCohort(params.get('cohort')));
	let inviteParam = $derived(params.get('invite'));

	let hasWallet = $state(false);
	let isMobile = $state(false);
	let squad = $state<ChainUnit | null>(null);
	let inviter = $state<ChainMember | null>(null);
	let member = $state<ChainMember | null>(null);
	let memberChecked = $state(false);
	let eth = $state<bigint | null>(null);
	let readError = $state<string | null>(null);
	const tx = new TxRunner();

	onMount(() => {
		hasWallet = wallet.hasWallet();
		isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
	});

	// The cohort squad and whoever sent the invite: public reads, no wallet needed.
	$effect(() => {
		const squadId = cohort.squadId;
		const invite = inviteParam;
		squad = null;
		inviter = null;
		if (squadId) loadUnit(squadId).then((u) => (squad = u)).catch(() => {});
		if (invite && isAddress(invite)) loadMember(invite).then((m) => (inviter = m)).catch(() => {});
	});

	async function readAccount(account: string) {
		try {
			const [m, balance] = await Promise.all([loadMember(account), loadEthBalance(account)]);
			if (!sameAddress(account, wallet.account)) return;
			member = m;
			eth = balance;
			readError = null;
		} catch (e) {
			readError = e instanceof Error ? e.message : 'Could not read the chain.';
		} finally {
			memberChecked = true;
		}
	}

	$effect(() => {
		const account = wallet.account;
		member = null;
		eth = null;
		memberChecked = false;
		if (account) readAccount(account);
	});

	// ── Steps ──────────────────────────────────────────────────
	type StepId = 'wallet' | 'connect' | 'network' | 'fees' | 'enlist';

	let enlistedHere = $derived(member !== null && cohort.squadId !== null && member.unitId === cohort.squadId);
	let done = $derived<Record<StepId, boolean>>({
		wallet: hasWallet || wallet.isConnected,
		connect: wallet.isConnected,
		network: wallet.isConnected && wallet.isCorrectNetwork,
		fees: member !== null || (eth !== null && eth >= MIN_FEE_BALANCE),
		enlist: enlistedHere,
	});
	const ORDER: StepId[] = ['wallet', 'connect', 'network', 'fees', 'enlist'];
	let current = $derived(ORDER.find((s) => !done[s]) ?? null);
	let doneCount = $derived(ORDER.filter((s) => done[s]).length);

	// While waiting on a faucet, check the balance every 10 seconds.
	$effect(() => {
		const account = wallet.account;
		if (current !== 'fees' || !account) return;
		const timer = setInterval(() => readAccount(account), 10_000);
		return () => clearInterval(timer);
	});

	const demo = isDemo();

	async function simulateFaucet() {
		demoFaucet();
		if (wallet.account) await readAccount(wallet.account);
	}

	let validInviter = $derived(inviter && !sameAddress(inviter.address, wallet.account) ? inviter : null);
	let enlistOpen = $derived(cohort.squadId !== null && squad?.active === true);

	async function enlist() {
		const squadId = cohort.squadId;
		if (!squadId) return;
		const ok = await tx.run(`Enlist in ${cohort.name}`, () => {
			const registry = getArmyRegistry(requireSigner());
			return validInviter ? registry.enlistWithInvite(squadId, validInviter.address) : registry.enlist(squadId);
		});
		if (ok && wallet.account) {
			await readAccount(wallet.account);
			void student.refresh(cohort, wallet.account);
		}
	}

	let phase = $derived(cohortPhase(cohort));
	let week = $derived(currentWeek(cohort));
	let statusPill = $derived(
		phase === 'running'
			? `In session · week ${week}`
			: phase === 'finished'
				? 'Finished'
				: enlistOpen
					? 'Enlisting now'
					: 'Opening soon'
	);
	let metamaskDeepLink = $derived(`https://metamask.app.link/dapp/${$page.url.host}${$page.url.pathname}${$page.url.search}`);
	let myInviteLink = $derived(wallet.account ? inviteLink($page.url.origin + resolve('/join'), cohort, wallet.account) : '');
</script>

<svelte:head>
	<title>Join {cohort.name} · Vanguard Academy</title>
	<meta name="description" content="{cohort.track}: {cohort.pitch}" />
</svelte:head>

<div class="join-bg min-h-screen">
	<header class="mx-auto flex max-w-6xl items-center justify-between px-4 py-5 sm:px-6">
		<a href={resolve('/join') + `?cohort=${cohort.id}`} class="flex items-center gap-3">
			<span class="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-cyan-500 to-cyan-700 text-sm font-bold text-white">V</span>
			<span class="flex flex-col leading-tight">
				<span class="text-sm font-semibold tracking-wide text-vanguard-text">VANGUARD</span>
				<span class="text-[10px] tracking-[0.2em] text-vanguard-text-muted">ACADEMY</span>
			</span>
		</a>
		<a href={resolve('/academy')} class="flex items-center gap-1.5 text-sm text-vanguard-text-muted transition-colors hover:text-cyan-300">
			<span class="hidden sm:inline">Already enlisted?</span> <span class="text-cyan-400">Open your cohort</span> <ArrowRight size={14} />
		</a>
	</header>

	<main class="mx-auto grid max-w-6xl grid-cols-1 gap-x-12 gap-y-8 px-4 pb-20 pt-6 sm:px-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,430px)] lg:pt-12">
		<!-- Pitch -->
		<section class="space-y-6 lg:col-start-1 lg:row-start-1">
			<div class="flex flex-wrap items-center gap-2">
				<span class="rounded-full border border-cyan-500/30 bg-cyan-500/10 px-3 py-1 font-mono text-[11px] uppercase tracking-[0.14em] text-cyan-300">
					{cohort.name} · {cohort.track}
				</span>
				<span class="rounded-full border border-vanguard-border bg-vanguard-surface px-3 py-1 text-[11px] text-vanguard-text-muted">{statusPill}</span>
			</div>
			<h1 class="text-4xl font-semibold leading-[1.08] tracking-tight text-vanguard-text sm:text-5xl">
				Train as a DeFi banker.
				<span class="block text-vanguard-text-muted">Earn your rank on chain.</span>
			</h1>
			<p class="max-w-xl text-base leading-relaxed text-vanguard-text-muted sm:text-lg">{cohort.pitch}</p>
			{#if !demo}
				<a
					href={resolve('/join') + `?cohort=${cohort.id}&demo=1`}
					data-sveltekit-reload
					class="inline-flex items-center gap-1.5 text-sm text-cyan-300 transition-colors hover:text-cyan-200"
				>
					Just looking? Preview the student experience with a simulated wallet <ArrowRight size={14} />
				</a>
				<a
					href={resolve('/instructor') + `?cohort=${cohort.id}&demo=instructor`}
					data-sveltekit-reload
					class="inline-flex items-center gap-1.5 text-sm text-amber-300/90 transition-colors hover:text-amber-200"
				>
					Running a cohort? Preview the instructor view <ArrowRight size={14} />
				</a>
			{/if}

			{#if validInviter && !enlistedHere}
				<div class="flex w-fit items-center gap-3 rounded-xl border border-amber-400/25 bg-amber-400/5 py-2 pl-2 pr-4">
					<RankInsignia rank={validInviter.rank} size="md" />
					<p class="text-sm text-vanguard-text">
						<span class="font-mono font-semibold">{validInviter.callsign}</span>
						<span class="text-vanguard-text-muted">· {RANK_META[validInviter.rank].label} · invited you</span>
					</p>
				</div>
			{/if}
		</section>

		<!-- Setup -->
		<aside class="lg:col-start-2 lg:row-span-2 lg:row-start-1">
			<div class="rounded-2xl border border-vanguard-border bg-vanguard-surface/90 shadow-[0_20px_60px_-30px_rgba(6,182,212,0.35)] backdrop-blur lg:sticky lg:top-6">
				{#if enlistedHere && member}
					<!-- Welcome -->
					<div class="space-y-6 p-6 sm:p-7">
						<div class="flex flex-col items-center gap-4 pt-2 text-center">
							<div class="welcome-pop emblem" style="--rank: {RANK_META[member.rank].color}" aria-hidden="true">
								<svg viewBox="0 0 24 24" width="38" height="38">
									<path d="M5 8.5l7 6 7-6" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" />
								</svg>
								<span class="font-mono text-[11px] font-bold tracking-[0.2em]">{member.rank}</span>
							</div>
							<div>
								<p class="font-mono text-[11px] uppercase tracking-[0.2em] text-amber-300">Welcome, {RANK_META[member.rank].label}</p>
								<h2 class="mt-1 font-mono text-3xl font-semibold tracking-wide text-vanguard-text">{member.callsign}</h2>
							</div>
							<p class="text-sm leading-relaxed text-vanguard-text-muted">
								You’re enlisted in {squad?.name ?? cohort.name}. Your callsign is how the guild knows you, and every piece of work you hand in is recorded against it.
							</p>
						</div>
						<a
							href={resolve('/academy')}
							class="flex w-full items-center justify-center gap-2 rounded-xl bg-cyan-500 px-4 py-3 text-sm font-semibold text-vanguard-bg transition-colors hover:bg-cyan-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-cyan-300"
						>
							Go to your cohort <ArrowRight size={16} />
						</a>
						<div class="space-y-2 border-t border-vanguard-border pt-5">
							<p class="text-sm font-medium text-vanguard-text">Bring someone with you</p>
							<p class="text-xs text-vanguard-text-muted">Anyone who enlists through your link is recorded as your recruit.</p>
							<CopyField value={myInviteLink} label="Copy link" />
						</div>
					</div>
				{:else}
					<div class="border-b border-vanguard-border px-6 pb-4 pt-5 sm:px-7">
						<div class="flex items-baseline justify-between">
							<h2 class="text-base font-semibold text-vanguard-text">Your setup</h2>
							<span class="font-mono text-xs text-vanguard-text-muted">{doneCount} of {ORDER.length} done</span>
						</div>
						<div class="mt-3 grid grid-cols-5 gap-1.5" aria-hidden="true">
							{#each ORDER as step}
								<div class="h-1 rounded-full transition-colors duration-500 {done[step] ? 'bg-emerald-400' : step === current ? 'bg-cyan-400' : 'bg-vanguard-surface-3'}"></div>
							{/each}
						</div>
						<p class="mt-3 text-xs text-vanguard-text-muted">About five minutes. Nothing here costs real money.</p>
					</div>

					<ol class="divide-y divide-vanguard-border">
						{#each ORDER as step, i}
							{@const isDone = done[step]}
							{@const isCurrent = step === current}
							<li class="px-6 py-4 sm:px-7" aria-current={isCurrent ? 'step' : undefined}>
								<div class="flex items-start gap-3.5">
									<span
										class="mt-0.5 flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full text-xs font-semibold transition-colors
											{isDone
												? 'bg-emerald-400/15 text-emerald-300'
												: isCurrent
													? 'bg-cyan-400 text-vanguard-bg ring-4 ring-cyan-400/15'
													: 'border border-vanguard-border text-vanguard-text-muted'}"
									>
										{#if isDone}<Check size={14} strokeWidth={3} />{:else}{i + 1}{/if}
									</span>
									<div class="min-w-0 flex-1">
										{#if step === 'wallet'}
											<h3 class="step-title" class:muted={!isCurrent && !isDone}>Install a wallet</h3>
											{#if isDone}
												<p class="step-note">Wallet found.</p>
											{:else if isCurrent}
												<div class="step-body">
													<p>A wallet is your login here. It holds no personal details: classmates see your callsign, and your work record is tied to the wallet.</p>
													<div class="flex flex-wrap gap-2">
														{#if isMobile}
															<a class="btn-primary" href={metamaskDeepLink}><Smartphone size={15} /> Open in MetaMask</a>
															<a class="btn-ghost" href="https://metamask.io/download/" target="_blank" rel="noopener">Get MetaMask <ExternalLink size={13} /></a>
														{:else}
															<a class="btn-primary" href="https://metamask.io/download/" target="_blank" rel="noopener">Install MetaMask <ExternalLink size={14} /></a>
														{/if}
														<button class="btn-ghost" onclick={() => location.reload()}><RefreshCw size={13} /> I’ve installed it</button>
													</div>
												</div>
											{/if}
										{:else if step === 'connect'}
											<h3 class="step-title" class:muted={!isCurrent && !isDone}>Connect it</h3>
											{#if isDone}
												<p class="step-note">Connected as <span class="font-mono">{shortAddress(wallet.account)}</span></p>
											{:else if isCurrent}
												<div class="step-body">
													<p>Your wallet asks whether to connect to Vanguard. Connecting shares your address and nothing else.</p>
													<button class="btn-primary" onclick={() => wallet.connect()} disabled={wallet.connecting}>
														{wallet.connecting ? 'Waiting for your wallet…' : 'Connect wallet'}
													</button>
													{#if wallet.error}<p class="text-xs text-red-300">{wallet.error}</p>{/if}
												</div>
											{/if}
										{:else if step === 'network'}
											<h3 class="step-title" class:muted={!isCurrent && !isDone}>Switch to Base Sepolia</h3>
											{#if isDone}
												<p class="step-note">On Base Sepolia.</p>
											{:else if isCurrent}
												<div class="step-body">
													<p>The cohort runs on Base Sepolia, a test network. Nothing on it costs real money, so you can practise freely.</p>
													<button class="btn-primary" onclick={() => wallet.switchToBaseSepolia()}>Switch network</button>
												</div>
											{/if}
										{:else if step === 'fees'}
											<h3 class="step-title" class:muted={!isCurrent && !isDone}>Get free test ETH for fees</h3>
											{#if isDone}
												<p class="step-note">
													{member ? 'Already enlisted.' : `${formatToken(eth ?? 0n, 4)} test ETH, enough for the course.`}
												</p>
											{:else if isCurrent}
												<div class="step-body">
													<p>Each thing you record, like enlisting or handing in work, is a small transaction with a fee in test ETH. A faucet gives it away free; 0.001 covers the whole course.</p>
													<div class="space-y-1.5">
														<p class="text-xs text-vanguard-text-muted">Your address, for the faucet:</p>
														<CopyField value={wallet.account ?? ''} />
													</div>
													<div class="flex flex-wrap gap-2">
														{#if demo}
															<button class="btn-primary" onclick={simulateFaucet}>Simulate a faucet payout</button>
														{:else}
															{#each FAUCETS as faucet, f}
																<a class={f === 0 ? 'btn-primary' : 'btn-ghost'} href={faucet.href} target="_blank" rel="noopener">
																	{faucet.label} <ExternalLink size={13} />
																</a>
															{/each}
														{/if}
													</div>
													<p class="flex items-center gap-2 text-xs text-vanguard-text-muted">
														<span class="h-1.5 w-1.5 animate-pulse rounded-full bg-cyan-400"></span>
														{memberChecked ? `Balance ${formatToken(eth ?? 0n, 4)} ETH.` : 'Checking your balance…'} We check again every 10 seconds.
													</p>
													<p class="text-xs text-vanguard-text-muted">Faucet not working? Send your address to your instructor and they’ll top you up.</p>
												</div>
											{/if}
										{:else}
											<h3 class="step-title" class:muted={!isCurrent && !isDone}>Enlist in {cohort.name}</h3>
											{#if isCurrent}
												<div class="step-body">
													{#if member}
														<p>
															This wallet is already enlisted as <span class="font-mono text-vanguard-text">{member.callsign}</span>, in another squad. Each wallet enlists once, so talk to your instructor about joining {cohort.name}.
														</p>
													{:else if !enlistOpen}
														<p>
															Enlistment opens shortly before the cohort starts. Keep this link: it will work then, and the steps above stay done.
														</p>
														{#if cohort.intakeUrl}
															<a class="btn-primary" href={cohort.intakeUrl} target="_blank" rel="noopener">Apply for a seat <ExternalLink size={14} /></a>
														{/if}
													{:else}
														<p>
															Enlisting records you on chain as a Private in {squad?.name ?? cohort.name} and gives you a callsign{validInviter ? `. It also records that ${validInviter.callsign} invited you` : ''}.
														</p>
														<button class="btn-primary" onclick={enlist} disabled={tx.busy || !memberChecked}>
															<Sparkles size={15} /> Enlist
														</button>
														<TxNotice {tx} doneText="Enlisted." />
													{/if}
												</div>
											{/if}
										{/if}
									</div>
								</div>
							</li>
						{/each}
					</ol>
					{#if readError}
						<p class="border-t border-vanguard-border px-6 py-3 text-xs text-red-300 sm:px-7" role="alert">{readError}</p>
					{/if}
				{/if}
			</div>
		</aside>

		<!-- Details -->
		<section class="space-y-10 lg:col-start-1 lg:row-start-2">
			<dl class="grid grid-cols-2 gap-3 sm:grid-cols-4">
				{#each [
					{ icon: CalendarDays, label: 'Dates', value: formatCohortDates(cohort) },
					{ icon: Clock, label: 'Length', value: `${cohort.weeks.length} weeks` },
					{ icon: Users, label: 'Seats', value: cohort.seats ? `${cohort.seats}` : 'Open' },
					{ icon: GraduationCap, label: 'Instructor', value: cohort.instructor.name },
				] as fact}
					<div class="rounded-xl border border-vanguard-border bg-vanguard-surface/70 px-4 py-3">
						<dt class="flex items-center gap-1.5 text-[11px] uppercase tracking-wider text-vanguard-text-muted">
							<fact.icon size={12} />
							{fact.label}
						</dt>
						<dd class="mt-1 text-sm font-medium text-vanguard-text">{fact.value}</dd>
					</div>
				{/each}
			</dl>

			<div class="space-y-4">
				<h2 class="text-lg font-semibold text-vanguard-text">The {cohort.weeks.length} weeks</h2>
				<ol class="grid gap-x-6 gap-y-3 sm:grid-cols-2">
					{#each cohort.weeks as w}
						<li class="flex gap-3">
							<span class="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-md border border-vanguard-border font-mono text-[11px] text-cyan-300">{w.week}</span>
							<div class="min-w-0">
								<p class="text-sm font-medium text-vanguard-text">{w.title}</p>
								<p class="text-xs leading-relaxed text-vanguard-text-muted">{w.summary}</p>
							</div>
						</li>
					{/each}
				</ol>
			</div>

			<div class="space-y-4">
				<h2 class="text-lg font-semibold text-vanguard-text">What you leave with</h2>
				<ul class="grid gap-2.5 sm:grid-cols-2">
					{#each cohort.outcomes as outcome}
						<li class="flex gap-2.5 text-sm text-vanguard-text-muted">
							<Check size={16} class="mt-0.5 flex-shrink-0 text-emerald-400" />
							{outcome}
						</li>
					{/each}
				</ul>
			</div>

			<p class="border-t border-vanguard-border pt-6 text-sm text-vanguard-text-muted">
				The guild runs on eight contracts on Base Sepolia, source verified.
				<a href={resolve('/') + 'live/'} data-sveltekit-reload class="text-cyan-300 hover:underline">See them read live</a>
			</p>
		</section>
	</main>
</div>

<style>
	.join-bg {
		background:
			radial-gradient(ellipse 80% 50% at 70% -10%, rgba(6, 182, 212, 0.14), transparent 60%),
			radial-gradient(ellipse 50% 40% at 0% 0%, rgba(251, 191, 36, 0.06), transparent 60%),
			var(--color-vanguard-bg);
	}
	.step-title {
		font-size: 0.9375rem;
		font-weight: 600;
		color: var(--color-vanguard-text);
		line-height: 1.75rem;
	}
	.step-title.muted {
		color: var(--color-vanguard-text-muted);
		font-weight: 500;
	}
	.step-note {
		font-size: 0.8125rem;
		color: var(--color-vanguard-text-muted);
	}
	.step-body {
		margin-top: 0.375rem;
		display: flex;
		flex-direction: column;
		gap: 0.875rem;
		font-size: 0.875rem;
		line-height: 1.6;
		color: var(--color-vanguard-text-muted);
	}
	.step-body :global(.btn-primary),
	.step-body :global(.btn-ghost) {
		width: fit-content;
	}
	.emblem {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.125rem;
		width: 6.5rem;
		height: 6.5rem;
		border-radius: 9999px;
		color: color-mix(in srgb, var(--rank) 55%, white);
		border: 2px solid color-mix(in srgb, var(--rank) 70%, transparent);
		background: radial-gradient(circle at 50% 35%, color-mix(in srgb, var(--rank) 30%, transparent), transparent 70%);
		box-shadow:
			0 0 0 6px color-mix(in srgb, var(--rank) 10%, transparent),
			0 0 40px -6px color-mix(in srgb, var(--rank) 60%, transparent);
	}
	.welcome-pop {
		animation: pop 0.5s cubic-bezier(0.2, 1.4, 0.4, 1) both;
	}
	@keyframes pop {
		from {
			transform: scale(0.6);
			opacity: 0;
		}
	}
	@media (prefers-reduced-motion: reduce) {
		.welcome-pop {
			animation: none;
		}
	}
</style>
