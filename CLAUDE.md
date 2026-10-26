# Vanguard

Start with [WORKPLAN.md](WORKPLAN.md): it holds the current priorities, what is done, the decisions waiting on the owner, and a session log to append to.

- **Contracts** (`contracts/`): eight contracts live on Base Sepolia since 27 Apr 2026 (`contracts/deployed/base-sepolia.json`). They stay unchanged until the "Academy release" in WORKPLAN.md; don't edit `.sol` files outside that release.
- **Web app** (`vanguard-ui/`, SvelteKit 2, Svelte 5 runes, Tailwind 4): a static site. `/join`, `/academy` and `/team` read and write the chain; the other pages still run on sample data from `src/lib/stores/mock-data.ts`. `?demo=1` runs everything against the simulated chain in `src/lib/demo/`. Check with `npm run check` and `BASE_PATH=/vanguard npm run build`.
- Internal links must go through `resolve()` from `$app/paths` and route matching through `$page.route.id`, because GitHub Pages serves the site under `/vanguard/`.
- **Deploy**: `.github/workflows/pages.yml` publishes the web app at the GitHub Pages root and the live contracts page (`live/index.html`) under `/live/` on every push to `main`.
- Brief and deliverable texts are on chain only as `keccak256(utf8(text))` fingerprints, the same convention as `contracts/scripts/demo.js`.
