<script lang="ts">
	import '../app.css';
	import Sidebar from '$components/Sidebar.svelte';
	import TopBar from '$components/TopBar.svelte';
	import NetworkBanner from '$components/NetworkBanner.svelte';
	import { app } from '$stores/app.svelte';

	let { children } = $props();
</script>

<NetworkBanner />

<div class="flex min-h-screen">
	<Sidebar />

	<div
		class="flex-1 flex flex-col transition-all duration-200"
		class:ml-60={!app.sidebarCollapsed}
		class:ml-16={app.sidebarCollapsed}
	>
		<TopBar />
		<main class="flex-1 p-6">
			{@render children()}
		</main>
	</div>
</div>
