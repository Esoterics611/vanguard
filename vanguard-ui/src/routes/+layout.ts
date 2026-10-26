// A static, browser-rendered site: every page is a wallet-driven client app.
// Static routes are prerendered as shells; dynamic ones fall back to 404.html.
export const ssr = false;
export const prerender = true;
