# Feed Page — Implementation Plan

## Overview
Add a **Feed** page (like a social media feed / Slack stream) — the team's real-time content stream showing:
- **Activity updates** — bounty created, tasks submitted/completed, objectives opened/merged, promotions
- **Course (bounty) updates** — progress on academy bounties, module completions
- **Mentions** — when someone @mentions you in an activity
- **Direct messages** — simple DM thread between two soldiers
- Future: channels (not yet, just feed + mentions + DMs for now)

---

## Files to Create / Modify

### 1. Types — `src/lib/types/index.ts`
Add new types:
```ts
FeedItemType = 'activity' | 'mention' | 'dm' | 'course_update' | 'system'

FeedItem {
  id, type, actorId, content, targetId?, targetType?, targetTitle?,
  mentions: string[],    // soldier IDs that are @mentioned
  channelId?: string,    // future: channel routing
  timestamp, metadata
}

DirectMessage {
  id, senderId, recipientId, content, timestamp, read: boolean
}
```

### 2. Mock Data — `src/lib/stores/mock-data.ts`
Add ~15-20 `MOCK_FEED_ITEMS` covering:
- Activity items (mirrors existing activities but richer — with content text)
- Course updates (RAVEN completed Module 1, SENTINEL starting Module 3, etc.)
- Mentions ("@PHOENIX please review the sensitivity tables")
- System announcements ("New bounty posted: Cross-Chain Bridge Security Assessment")

Add ~8 `MOCK_DIRECT_MESSAGES` between soldiers:
- Conversations between PHOENIX ↔ VIPER, PHOENIX ↔ NIGHTHAWK, etc.

### 3. App Store — `src/lib/stores/app.svelte.ts`
- Add `feedItems = $state<FeedItem[]>(MOCK_FEED_ITEMS)`
- Add `directMessages = $state<DirectMessage[]>(MOCK_DIRECT_MESSAGES)`
- Add derived: `myMentions` (feed items where currentUserId is in mentions[])
- Add derived: `myDMs` (messages where currentUserId is sender or recipient)
- Add derived: `unreadDMs` count
- Add helper: `getDMConversation(soldierId)` — returns sorted DMs between current user and target
- Add derived: `dmContacts` — list of soldiers with active DM threads

### 4. Route — `src/routes/feed/+page.svelte` (NEW)
The main Feed page with **3 tabs**:

#### Tab 1: "Stream" (default)
- Chronological feed of all FeedItems (newest first)
- Each item shows: actor avatar + callsign, content, target link, relative timestamp
- Activity items show the action icon (same `activityIcons` map from dashboard)
- Course updates highlighted with a special 🎓 or ◆ badge
- Mention items show `@CALLSIGN` highlighted in cyan
- System items styled with a subtle info bar

#### Tab 2: "Mentions"
- Filtered view showing only items where current user is mentioned
- Each shows context: who mentioned you, where, and the message
- Unread indicator dot

#### Tab 3: "Messages"
- Left panel: conversation list (contacts with last message preview + timestamp)
- Right panel: selected conversation thread
- Simple text input to "send" a new DM (adds to local state)
- Online indicator on each contact
- Unread dot on contacts with unread messages

#### UI Layout
- Tab bar at top (Stream | Mentions | Messages) with count badges
- Filter/search bar below tabs
- Scrollable card-based feed (matches existing card patterns)
- Compose area at bottom for DMs view

### 5. Sidebar — `src/lib/components/Sidebar.svelte`
- Add "Feed" nav item between Dashboard and Bounties
- Icon: `⊞` (or `◫`)
- Badge: unread mentions + unread DMs count

### 6. TopBar — `src/lib/components/TopBar.svelte`
- Add Feed to the page title lookup map

---

## Design Details

### Feed Item Card
```
┌─────────────────────────────────────────┐
│ [Avatar] CALLSIGN · action · 2h ago    │
│ Content text with @MENTION highlighted  │
│ ┌─ linked target ──────────────────┐   │
│ │ ◈ Bounty/Task title             │   │
│ └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### DM View
```
┌──────────┬──────────────────────────────┐
│ Contacts │  VIPER (SSG)           ●     │
│ ──────── │  ────────────────────────────│
│ • VIPER  │  [VIPER] Hey, the DCF...     │
│   NIGHT  │  [YOU]   On it, checking...  │
│   IRON   │  [VIPER] Thanks, also...     │
│          │                              │
│          │  ┌─────────────────── Send ┐ │
│          │  │ Type a message...       │ │
│          │  └────────────────────────┘ │
└──────────┴──────────────────────────────┘
```

### Styling
- Same cyberpunk dark theme tokens
- Feed cards use `card-hover` pattern
- Mention highlights: `text-cyan-400 bg-cyan-400/10 px-1 rounded`
- DM bubbles: sender = `bg-vanguard-surface-3`, me = `bg-cyan-500/10 border-cyan-500/20`
- Course update items get a gold accent border-left
- System items get a subtle `bg-vanguard-surface-2` full-width bar

---

## Implementation Order
1. Add types to `index.ts`
2. Add mock data to `mock-data.ts`
3. Update `app.svelte.ts` with new state + derivations
4. Create `src/routes/feed/+page.svelte` (the main page)
5. Update Sidebar nav + TopBar title map
6. Verify with dev server
