<script lang="ts">
	import { resolve } from '$app/paths';
	import { ArrowLeft, Clock, Coins, FileText, FingerprintPattern, Mail, Search, TriangleAlert } from 'lucide-svelte';

	const STEPS = [
		{
			icon: FileText,
			title: 'Do the work',
			body: 'Each week’s assignment and reading are on your cohort page. Write it in whatever you like (a document, a PDF, a spreadsheet) and save it as a file.',
		},
		{
			icon: FingerprintPattern,
			title: 'Submit it on your cohort page',
			body: 'Under Next up, choose the file, press Submit and confirm in your wallet. Your browser computes the file’s fingerprint, and only that goes on chain: nobody can read your work from it. The wallet asks for a small fee in free test ETH.',
		},
		{
			icon: Mail,
			title: 'Send the same file to your instructor',
			body: 'By email or in the cohort chat: the exact file you submitted. Your instructor drops it on your submission and the site checks that it matches the fingerprint before they approve.',
		},
		{
			icon: Search,
			title: 'Your instructor reviews it',
			body: 'Approved: you’re paid in VGRD at your rank’s pay rate. Sent back: your cohort page shows a short note on what to change. Fix it and hand it in again on the same assignment.',
		},
		{
			icon: Coins,
			title: 'Claim your pay',
			body: 'Approved pay collects on your cohort page until you press Claim to your wallet. Claim whenever you like.',
		},
	];

	const QUESTIONS = [
		{
			q: 'My instructor says the file doesn’t match.',
			a: 'They have a different version from the one you submitted. Send the exact file you submitted. If you no longer have it, ask them to send the work back, then submit the version you have and send them that.',
		},
		{
			q: 'I submitted the wrong file.',
			a: 'Tell your instructor. They send it back, and you submit the right one.',
		},
		{
			q: 'My wallet can’t pay the fee.',
			a: 'Fees are paid in test ETH, which is free. The Join page lists faucets that send you some.',
		},
		{
			q: 'I switched wallets and my progress is gone.',
			a: 'Your enlistment, rank and pay belong to the wallet you enlisted with. Switch back to that one.',
		},
	];
</script>

<svelte:head>
	<title>Handing in work · Vanguard Academy</title>
</svelte:head>

<div class="mx-auto max-w-3xl space-y-6">
	<a href={resolve('/academy')} class="inline-flex items-center gap-1.5 text-sm text-vanguard-text-muted hover:text-cyan-300">
		<ArrowLeft size={14} /> Back to your cohort
	</a>

	<section class="guide-hero rounded-2xl border border-vanguard-border px-6 py-6 sm:px-8">
		<p class="font-mono text-[11px] uppercase tracking-[0.18em] text-cyan-300">Student guide</p>
		<h2 class="mt-2 text-2xl font-semibold tracking-tight text-vanguard-text sm:text-3xl">Handing in work</h2>
		<p class="mt-2 max-w-2xl text-sm leading-relaxed text-vanguard-text-muted">
			Every assignment goes through the same five steps. Your work stays with you and your instructor; the chain records only its fingerprint, which proves what you handed in and when.
		</p>
	</section>

	<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface">
		<ol class="divide-y divide-vanguard-border">
			{#each STEPS as step, i}
				<li class="flex gap-4 px-6 py-5">
					<span class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-lg border border-cyan-400/30 bg-cyan-400/10 text-cyan-300">
						<step.icon size={17} />
					</span>
					<div class="min-w-0">
						<h3 class="text-sm font-semibold text-vanguard-text"><span class="mr-1.5 font-mono text-xs text-vanguard-text-muted">{i + 1}</span>{step.title}</h3>
						<p class="mt-1 text-sm leading-relaxed text-vanguard-text-muted">{step.body}</p>
					</div>
				</li>
			{/each}
		</ol>
	</section>

	<section class="flex gap-4 rounded-2xl border border-amber-400/25 bg-amber-400/5 px-6 py-5">
		<TriangleAlert size={18} class="mt-0.5 flex-shrink-0 text-amber-300" />
		<div class="space-y-2 text-sm leading-relaxed text-vanguard-text-muted">
			<h3 class="font-semibold text-amber-200">Keep the file exactly as you submitted it</h3>
			<p>Any change, even opening it and saving it again, can change the fingerprint. Keep an untouched copy of every file you submit.</p>
			<p>You can paste text instead of uploading a file. Then send your instructor exactly the same text. A file is safer: chat apps and email can quietly change spaces and line breaks.</p>
		</div>
	</section>

	<section class="flex gap-4 rounded-2xl border border-vanguard-border bg-vanguard-surface px-6 py-5">
		<Clock size={18} class="mt-0.5 flex-shrink-0 text-vanguard-text-muted" />
		<div class="space-y-1 text-sm leading-relaxed text-vanguard-text-muted">
			<h3 class="font-semibold text-vanguard-text">Deadlines</h3>
			<p>
				Most assignments are due at the end of their week. Once the deadline passes, that copy can’t be handed in any more, and nobody can extend it. Ask your instructor for a new copy: it shows up under Next up on your cohort page.
			</p>
		</div>
	</section>

	<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface px-6 py-5">
		<h3 class="text-sm font-semibold text-vanguard-text">If something goes wrong</h3>
		<dl class="mt-3 space-y-4">
			{#each QUESTIONS as item}
				<div>
					<dt class="text-sm font-medium text-vanguard-text">{item.q}</dt>
					<dd class="mt-0.5 text-sm leading-relaxed text-vanguard-text-muted">{item.a}</dd>
				</div>
			{/each}
		</dl>
		<p class="mt-5 text-xs text-vanguard-text-muted">
			Need test ETH? See the faucets on the <a href={resolve('/join')} class="text-cyan-300 hover:underline">Join page</a>.
		</p>
	</section>
</div>

<style>
	.guide-hero {
		background:
			radial-gradient(ellipse 60% 120% at 100% 0%, rgba(6, 182, 212, 0.12), transparent 60%),
			var(--color-vanguard-surface);
	}
</style>
