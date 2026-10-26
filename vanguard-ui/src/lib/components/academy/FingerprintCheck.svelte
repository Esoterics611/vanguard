<script lang="ts">
	import { Check, X } from 'lucide-svelte';
	import FingerprintInput from './FingerprintInput.svelte';

	/** expected: the fingerprint the student put on chain. matched: whether the reviewer's copy matches it. */
	let { expected, matched = $bindable(null) }: { expected: string; matched?: boolean | null } = $props();

	let fingerprint = $state<string | null>(null);

	$effect(() => {
		matched = fingerprint ? fingerprint.toLowerCase() === expected.toLowerCase() : null;
	});
</script>

<div class="space-y-2">
	<FingerprintInput bind:fingerprint prompt="Drop the student’s file to check it" placeholder="Paste the student’s text here, exactly as they sent it" compact />
	{#if matched === true}
		<p class="flex items-center gap-1.5 text-sm text-emerald-300"><Check size={15} /> Matches what the student submitted.</p>
	{:else if matched === false}
		<p class="flex items-start gap-1.5 text-sm text-red-300">
			<X size={15} class="mt-0.5 flex-shrink-0" />
			Doesn’t match. Ask the student for the exact file they submitted; any edit changes the fingerprint.
		</p>
	{/if}
</div>
