<script lang="ts">
	import '../app.css';
	import { onMount, untrack } from 'svelte';
	import { page } from '$app/stores';
	import Sidebar from '$components/Sidebar.svelte';
	import TopBar from '$components/TopBar.svelte';
	import NetworkBanner from '$components/NetworkBanner.svelte';
	import { app } from '$stores/app.svelte';
	import { wallet } from '$lib/contracts/provider.svelte';
	import { student } from '$lib/academy/student.svelte';
	import { getCohort } from '$lib/academy/cohorts';

	let { children } = $props();

	// Pages that still run on the demo team in mock-data.ts rather than the contracts.
	const SAMPLE_ROUTES = ['/bounties', '/objectives', '/tasks', '/review', '/settings', '/team/'];

	let path = $derived($page.url.pathname);
	// /join is a focused, full-screen flow without the app chrome.
	let bare = $derived(path === '/join' || path.startsWith('/join/'));
	let sample = $derived(path === '/' || SAMPLE_ROUTES.some((r) => path.startsWith(r)));

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
					<a href="/academy" class="underline underline-offset-2 hover:text-amber-100">Academy</a> and
					<a href="/team" class="underline underline-offset-2 hover:text-amber-100">Team</a>.
				</div>
			{/if}
			<main class="flex-1 p-4 sm:p-6">
				{@render children()}
			</main>
		</div>
	</div>
{/if}
