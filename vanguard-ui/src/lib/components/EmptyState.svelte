<script lang="ts">
	interface Props {
		icon?: string;
		title: string;
		description?: string;
	}

	let { icon = '◇', title, description }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center py-16 text-center">
	<span class="text-3xl text-vanguard-border mb-4">{icon}</span>
	<h3 class="text-sm font-medium text-vanguard-text-muted mb-1">{title}</h3>
	{#if description}
		<p class="text-xs text-vanguard-text-muted/60 max-w-xs">{description}</p>
	{/if}
</div>
