// Formatting utilities

export function formatVgrd(amount: number): string {
	if (amount >= 1_000_000) return `${(amount / 1_000_000).toFixed(1)}M`;
	if (amount >= 1_000) return `${(amount / 1_000).toFixed(1)}K`;
	return amount.toLocaleString();
}

export function formatDate(iso: string): string {
	const d = new Date(iso);
	const now = new Date();
	const diffMs = now.getTime() - d.getTime();
	const diffHours = diffMs / (1000 * 60 * 60);
	const diffDays = diffMs / (1000 * 60 * 60 * 24);

	if (diffHours < 1) return `${Math.floor(diffMs / 60000)}m ago`;
	if (diffHours < 24) return `${Math.floor(diffHours)}h ago`;
	if (diffDays < 7) return `${Math.floor(diffDays)}d ago`;
	if (diffDays < 365) return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
	return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

export function formatDeadline(iso: string): { text: string; urgent: boolean; overdue: boolean } {
	const d = new Date(iso);
	const now = new Date();
	const diffMs = d.getTime() - now.getTime();
	const diffDays = diffMs / (1000 * 60 * 60 * 24);

	if (diffDays < 0) return { text: `${Math.abs(Math.floor(diffDays))}d overdue`, urgent: true, overdue: true };
	if (diffDays < 3) return { text: `${Math.floor(diffDays)}d left`, urgent: true, overdue: false };
	if (diffDays < 30) return { text: `${Math.floor(diffDays)}d left`, urgent: false, overdue: false };
	return { text: d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }), urgent: false, overdue: false };
}

export function truncate(str: string, len: number): string {
	return str.length > len ? str.slice(0, len) + '...' : str;
}

export function statusColor(status: string): string {
	const map: Record<string, string> = {
		// Bounty
		draft: 'text-zinc-400 bg-zinc-400/10',
		active: 'text-cyan-400 bg-cyan-400/10',
		in_progress: 'text-amber-400 bg-amber-400/10',
		completed: 'text-emerald-400 bg-emerald-400/10',
		cancelled: 'text-red-400 bg-red-400/10',
		// Objective
		open: 'text-cyan-400 bg-cyan-400/10',
		in_review: 'text-purple-400 bg-purple-400/10',
		merged: 'text-emerald-400 bg-emerald-400/10',
		closed: 'text-zinc-400 bg-zinc-400/10',
		// Task
		todo: 'text-zinc-400 bg-zinc-400/10',
		assigned: 'text-blue-400 bg-blue-400/10',
		blocked: 'text-red-400 bg-red-400/10',
		submitted: 'text-purple-400 bg-purple-400/10',
		approved: 'text-emerald-400 bg-emerald-400/10',
		rejected: 'text-red-400 bg-red-400/10',
	};
	return map[status] ?? 'text-zinc-400 bg-zinc-400/10';
}

export function statusLabel(status: string): string {
	return status.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
}

export function priorityColor(priority: string): string {
	const map: Record<string, string> = {
		low: 'text-zinc-400',
		medium: 'text-blue-400',
		high: 'text-amber-400',
		critical: 'text-red-400',
	};
	return map[priority] ?? 'text-zinc-400';
}

export function tierColor(tier: string): string {
	const map: Record<string, string> = {
		enlisted: 'text-amber-700',
		nco: 'text-slate-300',
		officer: 'text-yellow-400',
	};
	return map[tier] ?? 'text-zinc-400';
}
