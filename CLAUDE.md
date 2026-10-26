# Vanguard

Start with [WORKPLAN.md](WORKPLAN.md): it holds the current priorities, what is done, the decisions waiting on the owner, and a session log to append to.

- **Contracts** (`contracts/`): eight contracts live on Base Sepolia since 27 Apr 2026 (`contracts/deployed/base-sepolia.json`). They stay unchanged until the "Academy release" in WORKPLAN.md; don't edit `.sol` files outside that release.
- **Web app** (`vanguard-ui/`, SvelteKit 2, Svelte 5 runes, Tailwind 4): `/join`, `/academy` and `/team` read and write the chain; the other pages still run on sample data from `src/lib/stores/mock-data.ts`. Check with `npm run check` and `npm run build`.
- **Live page** (`live/index.html`): a static page that reads the contracts, published to GitHub Pages by `.github/workflows/pages.yml`.
- Brief and deliverable texts are on chain only as `keccak256(utf8(text))` fingerprints, the same convention as `contracts/scripts/demo.js`.
