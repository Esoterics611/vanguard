<script lang="ts">
	import { statusColor, statusLabel } from '$lib/utils/format';

	interface Props {
		status: string;
		size?: 'sm' | 'md';
	}

	let { status, size = 'sm' }: Props = $props();
</script>

<span
	class="tag {statusColor(status)}"
	class:text-xs={size === 'sm'}
	class:text-sm={size === 'md'}
>
	{statusLabel(status)}
</span>
