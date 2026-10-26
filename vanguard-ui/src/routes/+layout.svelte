<script lang="ts">
	import { resolve } from '$app/paths';
	import '../app.css';
	import { onMount, untrack } from 'svelte';
	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import Sidebar from '$components/Sidebar.svelte';
	import TopBar from '$components/TopBar.svelte';
	import NetworkBanner from '$components/NetworkBanner.svelte';
	import { app } from '$stores/app.svelte';
	import { wallet } from '$lib/contracts/provider.svelte';
	import { student } from '$lib/academy/student.svelte';
	import { getCohort } from '$lib/academy/cohorts';
	import { isDemo, leaveDemo } from '$lib/demo/flag';
	import { installDemo } from '$lib/demo/mock-chain';

	let { children } = $props();

	// Demo mode swaps in the simulated wallet before any page looks for one.
	const demo = browser && isDemo();
	if (demo) installDemo();

	function exitDemo() {
		leaveDemo();
		window.location.href = resolve('/join');
	}

	// Pages that still run on the demo team in mock-data.ts rather than the contracts.
	const SAMPLE_ROUTES = ['/dashboard', '/bounties', '/objectives', '/tasks', '/review', '/settings', '/team/'];

	// Route ids, not URL paths, so the deploy base path doesn't matter.
	let route = $derived($page.route.id ?? '');
	let path = $derived($page.url.pathname);
	// /join is a focused, full-screen flow without the app chrome.
	let bare = $derived(route === '/join');
	let sample = $derived(SAMPLE_ROUTES.some((r) => route.startsWith(r)));

	onMount(() => {
		void wallet.restore();
	});

	// The mobile menu closes whenever the page changes.
	$effect(() => {
		void path;
		untrack(() => (app.mobileNavOpen = false));
	});

	// Load the student's cohort data whenever the connected wallet changes.
	$effect(() => {
		const account = wallet.account;
		untrack(() => student.refresh(getCohort(student.cohortId), account));
	});
</script>

<svelte:window onkeydown={(e) => e.key === 'Escape' && (app.mobileNavOpen = false)} />

{#if demo}
	<!-- Phones: a slim bar in the page flow, so it never covers a button. -->
	<div class="flex items-center justify-between gap-3 border-b border-amber-300/30 bg-amber-300/10 px-4 py-1.5 text-xs text-amber-100 sm:hidden" role="status">
		<span><span class="font-semibold text-amber-300">Demo</span> · nothing is recorded</span>
		<button onclick={exitDemo} class="font-medium text-amber-200 underline underline-offset-2">Leave demo</button>
	</div>
	<!-- Wider screens: a floating label in the corner. -->
	<div
		class="fixed bottom-4 right-4 z-50 hidden items-center gap-3 whitespace-nowrap rounded-full border border-amber-300/40 bg-vanguard-surface/95 py-1.5 pl-4 pr-1.5 text-xs text-amber-100 shadow-lg shadow-black/40 backdrop-blur sm:flex"
		role="status"
	>
		<span class="h-1.5 w-1.5 animate-pulse rounded-full bg-amber-300"></span>
		<span><span class="font-semibold text-amber-300">Demo</span> · simulated wallet and chain, nothing is recorded</span>
		<button onclick={exitDemo} class="rounded-full bg-amber-300/15 px-3 py-1 font-medium text-amber-200 hover:bg-amber-300/25">Leave demo</button>
	</div>
{/if}

{#if bare}
	{@render children()}
{:else}
	<NetworkBanner />
	<div class="flex min-h-screen">
		<Sidebar />

		{#if app.mobileNavOpen}
			<button
				class="fixed inset-0 z-30 bg-black/60 lg:hidden"
				aria-label="Close menu"
				onclick={() => (app.mobileNavOpen = false)}
			></button>
		{/if}

		<div class="flex-1 flex flex-col min-w-0 transition-all duration-200 {app.sidebarCollapsed ? 'lg:ml-16' : 'lg:ml-60'}">
			<TopBar />
			{#if sample}
				<div class="border-b border-amber-400/20 bg-amber-400/5 px-4 sm:px-6 py-2 text-xs text-amber-200/90">
					Sample data: this page shows a demo team, not the live contracts. Live pages are
					<a href={resolve('/academy')} class="underline underline-offset-2 hover:text-amber-100">Academy</a> and
					<a href={resolve('/team')} class="underline underline-offset-2 hover:text-amber-100">Team</a>.
				</div>
			{/if}
			<main class="flex-1 p-4 sm:p-6">
				{@render children()}
			</main>
		</div>
	</div>
{/if}
