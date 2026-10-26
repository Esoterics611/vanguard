import { redirect } from '@sveltejs/kit';
import { resolve } from '$app/paths';

// The site's front door is the cohort page.
export function load() {
	redirect(307, resolve('/join'));
}
