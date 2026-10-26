import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),
	kit: {
		// A static site: pages render in the browser, and 404.html serves any
		// path that wasn't prerendered (the /team/[id]-style pages), so it runs
		// on GitHub Pages, Vercel, Netlify or any file host.
		adapter: adapter({ fallback: '404.html' }),
		paths: {
			// '' at a domain root; '/vanguard' on GitHub Pages (set by the deploy workflow).
			base: process.env.BASE_PATH ?? '',
		},
		alias: {
			$lib: './src/lib',
			$components: './src/lib/components',
			$stores: './src/lib/stores',
			$types: './src/lib/types'
		}
	}
};

export default config;
