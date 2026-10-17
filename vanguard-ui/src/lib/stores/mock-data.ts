// ═══════════════════════════════════════════════════════════════
// Mock data for the Vanguard DAO UI
// Simulates an investment banking team working through the system
// Replace with Firebase/API calls when connecting to backend
// ═══════════════════════════════════════════════════════════════

import type { Soldier, Bounty, Objective, Task, Activity, Unit } from '$lib/types';

// ── Soldiers (Investment Banking Team) ─────────────────────────
export const MOCK_SOLDIERS: Soldier[] = [
	{
		id: 'sol-001', callsign: 'IRONFORGE', walletAddress: '0x1a2b...3c4d', rank: 'CPT',
		xp: 42000, vgrdEarned: 185000, votingPower: 50, tasksCompleted: 312,
		squadId: null, sectionId: null, platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Deal Structuring', avatarUrl: null, enlistedAt: '2024-01-15T00:00:00Z', isOnline: true
	},
	{
		id: 'sol-002', callsign: 'NIGHTHAWK', walletAddress: '0x2b3c...4d5e', rank: '1LT',
		xp: 28000, vgrdEarned: 95000, votingPower: 35, tasksCompleted: 198,
		squadId: null, sectionId: 'sec-001', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'M&A Advisory', avatarUrl: null, enlistedAt: '2024-02-20T00:00:00Z', isOnline: true
	},
	{
		id: 'sol-003', callsign: 'VIPER', walletAddress: '0x3c4d...5e6f', rank: 'SSG',
		xp: 3200, vgrdEarned: 42000, votingPower: 15, tasksCompleted: 87,
		squadId: 'sq-001', sectionId: 'sec-001', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Financial Modeling', avatarUrl: null, enlistedAt: '2024-03-10T00:00:00Z', isOnline: false
	},
	{
		id: 'sol-004', callsign: 'PHOENIX', walletAddress: '0x4d5e...6f7g', rank: 'SGT',
		xp: 1800, vgrdEarned: 28000, votingPower: 10, tasksCompleted: 64,
		squadId: 'sq-001', sectionId: 'sec-001', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Due Diligence', avatarUrl: null, enlistedAt: '2024-04-05T00:00:00Z', isOnline: true
	},
	{
		id: 'sol-005', callsign: 'SPECTER', walletAddress: '0x5e6f...7g8h', rank: 'CPL',
		xp: 850, vgrdEarned: 12000, votingPower: 5, tasksCompleted: 31,
		squadId: 'sq-002', sectionId: 'sec-001', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Market Research', avatarUrl: null, enlistedAt: '2024-05-12T00:00:00Z', isOnline: true
	},
	{
		id: 'sol-006', callsign: 'RAVEN', walletAddress: '0x6f7g...8h9i', rank: 'PFC',
		xp: 420, vgrdEarned: 6500, votingPower: 3, tasksCompleted: 18,
		squadId: 'sq-002', sectionId: 'sec-001', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Pitch Decks', avatarUrl: null, enlistedAt: '2024-06-01T00:00:00Z', isOnline: false
	},
	{
		id: 'sol-007', callsign: 'WRAITH', walletAddress: '0x7g8h...9i0j', rank: 'SGT',
		xp: 1500, vgrdEarned: 22000, votingPower: 10, tasksCompleted: 55,
		squadId: 'sq-003', sectionId: 'sec-002', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Valuation', avatarUrl: null, enlistedAt: '2024-03-22T00:00:00Z', isOnline: true
	},
	{
		id: 'sol-008', callsign: 'SENTINEL', walletAddress: '0x8h9i...0j1k', rank: 'PV2',
		xp: 150, vgrdEarned: 3200, votingPower: 2, tasksCompleted: 8,
		squadId: 'sq-003', sectionId: 'sec-002', platoonId: 'plt-001', companyId: 'co-001',
		specialty: 'Data Analysis', avatarUrl: null, enlistedAt: '2024-07-15T00:00:00Z', isOnline: true
	}
];

// ── Units ──────────────────────────────────────────────────────
export const MOCK_UNITS: Unit[] = [
	{
		id: 'co-001', type: 'company', name: 'Alpha Company', leaderId: 'sol-001',
		secondInCommandId: 'sol-002', memberIds: MOCK_SOLDIERS.map(s => s.id),
		parentUnitId: null, childUnitIds: ['plt-001'], objectiveIds: []
	},
	{
		id: 'plt-001', type: 'platoon', name: '1st Platoon — M&A Division', leaderId: 'sol-002',
		secondInCommandId: null, memberIds: MOCK_SOLDIERS.filter(s => s.id !== 'sol-001').map(s => s.id),
		parentUnitId: 'co-001', childUnitIds: ['sec-001', 'sec-002'], objectiveIds: []
	},
	{
		id: 'sec-001', type: 'section', name: 'Deal Execution Section', leaderId: 'sol-003',
		secondInCommandId: 'sol-004', memberIds: ['sol-003', 'sol-004', 'sol-005', 'sol-006'],
		parentUnitId: 'plt-001', childUnitIds: ['sq-001', 'sq-002'], objectiveIds: ['obj-001', 'obj-002']
	},
	{
		id: 'sec-002', type: 'section', name: 'Research & Valuation Section', leaderId: 'sol-007',
		secondInCommandId: null, memberIds: ['sol-007', 'sol-008'],
		parentUnitId: 'plt-001', childUnitIds: ['sq-003'], objectiveIds: ['obj-003']
	},
	{
		id: 'sq-001', type: 'squad', name: 'Modeling Squad', leaderId: 'sol-003',
		secondInCommandId: null, memberIds: ['sol-003', 'sol-004'],
		parentUnitId: 'sec-001', childUnitIds: [], objectiveIds: []
	},
	{
		id: 'sq-002', type: 'squad', name: 'Research Squad', leaderId: 'sol-005',
		secondInCommandId: null, memberIds: ['sol-005', 'sol-006'],
		parentUnitId: 'sec-001', childUnitIds: [], objectiveIds: []
	},
	{
		id: 'sq-003', type: 'squad', name: 'Valuation Squad', leaderId: 'sol-007',
		secondInCommandId: null, memberIds: ['sol-007', 'sol-008'],
		parentUnitId: 'sec-002', childUnitIds: [], objectiveIds: []
	}
];

// ── Bounties (= Repositories / Deals) ─────────────────────────
export const MOCK_BOUNTIES: Bounty[] = [
	{
		id: 'bounty-001',
		title: 'Series B Due Diligence — TechCorp Acquisition',
		description: 'Complete due diligence package for the proposed TechCorp acquisition. Includes financial modeling, market analysis, competitive landscape, and risk assessment. Target close: Q2 2025.',
		creatorId: 'sol-001', totalAmount: 50000, remainingAmount: 18000,
		status: 'in_progress', category: 'deal', objectiveIds: ['obj-001', 'obj-002', 'obj-003'],
		skillTags: ['M&A', 'Due Diligence', 'Financial Modeling', 'Valuation'],
		deadline: '2025-06-30T00:00:00Z', createdAt: '2025-01-10T00:00:00Z', updatedAt: '2025-01-28T00:00:00Z'
	},
	{
		id: 'bounty-002',
		title: 'DeFi Protocol Tokenomics Audit',
		description: 'Comprehensive tokenomics review and restructuring proposal for the Meridian DeFi protocol. Analyze token distribution, inflation schedule, and governance mechanisms.',
		creatorId: 'sol-001', totalAmount: 30000, remainingAmount: 30000,
		status: 'active', category: 'deal', objectiveIds: ['obj-004', 'obj-005'],
		skillTags: ['Tokenomics', 'DeFi', 'Governance', 'Economic Modeling'],
		deadline: '2025-08-15T00:00:00Z', createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z'
	},
	{
		id: 'bounty-003',
		title: 'DAO Treasury Diversification Strategy',
		description: 'Develop a risk-adjusted treasury diversification strategy for the Vanguard DAO treasury. Include yield farming analysis, stablecoin allocation, and RWA exposure recommendations.',
		creatorId: 'sol-002', totalAmount: 25000, remainingAmount: 25000,
		status: 'active', category: 'deal', objectiveIds: ['obj-006'],
		skillTags: ['Treasury', 'Risk Management', 'Yield Farming', 'RWA'],
		deadline: '2025-09-01T00:00:00Z', createdAt: '2025-01-25T00:00:00Z', updatedAt: '2025-01-25T00:00:00Z'
	},
	{
		id: 'bounty-004',
		title: 'Cross-Chain Bridge Security Assessment',
		description: 'Security audit and risk assessment of three major cross-chain bridge protocols for potential integration.',
		creatorId: 'sol-001', totalAmount: 40000, remainingAmount: 40000,
		status: 'draft', category: 'deal', objectiveIds: [],
		skillTags: ['Security', 'Cross-Chain', 'Audit', 'Smart Contracts'],
		deadline: '2025-10-01T00:00:00Z', createdAt: '2025-01-28T00:00:00Z', updatedAt: '2025-01-28T00:00:00Z'
	},
	// ── Academy Bounties (Courses) ─────────────────────────────────
	{
		id: 'bounty-acad-001',
		title: 'Analyst Bootcamp — Financial Modeling Fundamentals',
		description: 'Entry-level training covering 3-statement modeling, DCF basics, and comparable company analysis. Required for all new analysts before deal assignments.',
		creatorId: 'sol-002', totalAmount: 15000, remainingAmount: 6000,
		status: 'in_progress', category: 'academy', objectiveIds: ['obj-acad-001', 'obj-acad-002', 'obj-acad-003'],
		skillTags: ['Training', 'Financial Modeling', 'DCF', 'Comps'],
		deadline: '2025-05-30T00:00:00Z', createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z'
	},
	{
		id: 'bounty-acad-002',
		title: 'Associate Track — M&A Process & Execution',
		description: 'Advanced course covering end-to-end M&A deal lifecycle: origination, due diligence frameworks, valuation, negotiation, and post-merger integration.',
		creatorId: 'sol-001', totalAmount: 20000, remainingAmount: 14000,
		status: 'in_progress', category: 'academy', objectiveIds: ['obj-acad-004', 'obj-acad-005'],
		skillTags: ['Training', 'M&A', 'Due Diligence', 'Negotiation'],
		deadline: '2025-07-15T00:00:00Z', createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-26T00:00:00Z'
	},
	{
		id: 'bounty-acad-003',
		title: 'Specialist Certification — DeFi & Tokenomics',
		description: 'Specialized training on DeFi protocol mechanics, token valuation models, and on-chain analytics. For soldiers moving into crypto-native deal work.',
		creatorId: 'sol-001', totalAmount: 12000, remainingAmount: 12000,
		status: 'active', category: 'academy', objectiveIds: ['obj-acad-006'],
		skillTags: ['Training', 'DeFi', 'Tokenomics', 'On-Chain Analytics'],
		deadline: '2025-09-01T00:00:00Z', createdAt: '2025-01-22T00:00:00Z', updatedAt: '2025-01-22T00:00:00Z'
	}
];

// ── Objectives (= Pull Requests / Workstreams) ─────────────────
export const MOCK_OBJECTIVES: Objective[] = [
	{
		id: 'obj-001', title: 'Financial Model & Projections', description: 'Build comprehensive 5-year DCF model with sensitivity analysis, revenue build-up, and working capital projections.',
		bountyId: 'bounty-001', unitId: 'sq-001', assigneeId: 'sol-003',
		status: 'in_progress', taskIds: ['task-001', 'task-002', 'task-003', 'task-004'],
		allocatedVgrd: 18000, deadline: '2025-04-15T00:00:00Z',
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-26T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-002', title: 'Market & Competitive Analysis', description: 'Deep-dive market sizing, TAM/SAM/SOM analysis, and competitive positioning matrix with 15+ comparable companies.',
		bountyId: 'bounty-001', unitId: 'sq-002', assigneeId: 'sol-005',
		status: 'in_review', taskIds: ['task-005', 'task-006', 'task-007'],
		allocatedVgrd: 14000, deadline: '2025-03-30T00:00:00Z',
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-003', title: 'Comparable Company Valuation', description: 'Trading comps analysis with 20+ public comparables, including EV/Revenue, EV/EBITDA, and P/E multiples.',
		bountyId: 'bounty-001', unitId: 'sq-003', assigneeId: 'sol-007',
		status: 'in_progress', taskIds: ['task-008', 'task-009'],
		allocatedVgrd: 12000, deadline: '2025-04-30T00:00:00Z',
		createdAt: '2025-01-14T00:00:00Z', updatedAt: '2025-01-25T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-004', title: 'Token Distribution Analysis', description: 'Map current token distribution, identify concentration risks, and model vesting schedule impacts.',
		bountyId: 'bounty-002', unitId: null, assigneeId: null,
		status: 'open', taskIds: ['task-010', 'task-011'],
		allocatedVgrd: 15000, deadline: '2025-07-15T00:00:00Z',
		createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-005', title: 'Governance Mechanism Review', description: 'Analyze voting mechanics, quorum requirements, and propose improvements to reduce voter apathy.',
		bountyId: 'bounty-002', unitId: null, assigneeId: null,
		status: 'open', taskIds: ['task-012'],
		allocatedVgrd: 15000, deadline: '2025-08-01T00:00:00Z',
		createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-006', title: 'Yield Strategy Research', description: 'Research and benchmark top DeFi yield strategies, assess risk-adjusted returns for treasury allocation.',
		bountyId: 'bounty-003', unitId: null, assigneeId: null,
		status: 'open', taskIds: [],
		allocatedVgrd: 25000, deadline: '2025-08-15T00:00:00Z',
		createdAt: '2025-01-25T00:00:00Z', updatedAt: '2025-01-25T00:00:00Z', reviewComment: null
	},
	// ── Academy Objectives (Course Modules) ────────────────────────
	{
		id: 'obj-acad-001', title: 'Module 1: 3-Statement Modeling', description: 'Build a fully linked income statement, balance sheet, and cash flow statement from scratch.',
		bountyId: 'bounty-acad-001', unitId: 'sq-001', assigneeId: 'sol-004',
		status: 'merged', taskIds: ['task-acad-001', 'task-acad-002'],
		allocatedVgrd: 5000, deadline: '2025-02-28T00:00:00Z',
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z', reviewComment: 'Clean model. Well structured.'
	},
	{
		id: 'obj-acad-002', title: 'Module 2: DCF Fundamentals', description: 'Learn discounted cash flow methodology — free cash flow projection, WACC calculation, and terminal value.',
		bountyId: 'bounty-acad-001', unitId: 'sq-001', assigneeId: 'sol-006',
		status: 'in_progress', taskIds: ['task-acad-003', 'task-acad-004'],
		allocatedVgrd: 5000, deadline: '2025-04-15T00:00:00Z',
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-acad-003', title: 'Module 3: Comparable Company Analysis', description: 'Screen, select, and analyze public comparables. Calculate trading multiples and apply to target.',
		bountyId: 'bounty-acad-001', unitId: null, assigneeId: 'sol-008',
		status: 'open', taskIds: ['task-acad-005'],
		allocatedVgrd: 5000, deadline: '2025-05-15T00:00:00Z',
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-05T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-acad-004', title: 'Module 1: Deal Origination & Screening', description: 'Understand deal sourcing, initial screening criteria, and how to evaluate opportunities.',
		bountyId: 'bounty-acad-002', unitId: 'sq-002', assigneeId: 'sol-005',
		status: 'in_progress', taskIds: ['task-acad-006', 'task-acad-007'],
		allocatedVgrd: 10000, deadline: '2025-04-30T00:00:00Z',
		createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-25T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-acad-005', title: 'Module 2: Due Diligence Frameworks', description: 'Build a comprehensive DD checklist covering financial, legal, operational, and technology diligence.',
		bountyId: 'bounty-acad-002', unitId: null, assigneeId: null,
		status: 'open', taskIds: ['task-acad-008'],
		allocatedVgrd: 10000, deadline: '2025-06-30T00:00:00Z',
		createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-08T00:00:00Z', reviewComment: null
	},
	{
		id: 'obj-acad-006', title: 'Module 1: Token Valuation Models', description: 'Learn to value tokens using comparable protocol analysis, discounted fee models, and network value approaches.',
		bountyId: 'bounty-acad-003', unitId: null, assigneeId: null,
		status: 'open', taskIds: [],
		allocatedVgrd: 12000, deadline: '2025-08-15T00:00:00Z',
		createdAt: '2025-01-22T00:00:00Z', updatedAt: '2025-01-22T00:00:00Z', reviewComment: null
	}
];

// ── Tasks (= Commits / Individual Work Items) ──────────────────
export const MOCK_TASKS: Task[] = [
	// obj-001 tasks (Financial Model)
	{
		id: 'task-001', title: 'Revenue build-up model', description: 'Build bottoms-up revenue model with segment-level assumptions. Include customer cohort analysis and pricing sensitivity.',
		objectiveId: 'obj-001', bountyId: 'bounty-001', assigneeId: 'sol-003',
		status: 'approved', priority: 'high', rewardVgrd: 5000,
		deadline: '2025-02-15T00:00:00Z', submissionHash: 'QmX7b2...abc123',
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-24T00:00:00Z'
	},
	{
		id: 'task-002', title: 'DCF model with WACC calculation', description: 'Full DCF model with detailed WACC build-up, terminal value (both perpetuity growth and exit multiple), and football field summary.',
		objectiveId: 'obj-001', bountyId: 'bounty-001', assigneeId: 'sol-003',
		status: 'in_progress', priority: 'critical', rewardVgrd: 6000,
		deadline: '2025-03-01T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-28T00:00:00Z'
	},
	{
		id: 'task-003', title: 'Sensitivity tables', description: 'Create sensitivity/scenario analysis: Bull/Base/Bear cases with key driver matrix (growth rate × margin × multiple).',
		objectiveId: 'obj-001', bountyId: 'bounty-001', assigneeId: 'sol-004',
		status: 'assigned', priority: 'medium', rewardVgrd: 3500,
		deadline: '2025-03-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-14T00:00:00Z', updatedAt: '2025-01-14T00:00:00Z'
	},
	{
		id: 'task-004', title: 'Working capital analysis', description: 'Analyze historical working capital trends, model future NWC requirements, and assess cash conversion cycle.',
		objectiveId: 'obj-001', bountyId: 'bounty-001', assigneeId: 'sol-004',
		status: 'todo', priority: 'medium', rewardVgrd: 3500,
		deadline: '2025-04-01T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-14T00:00:00Z', updatedAt: '2025-01-14T00:00:00Z'
	},
	// obj-002 tasks (Market Analysis)
	{
		id: 'task-005', title: 'TAM/SAM/SOM analysis', description: 'Top-down and bottom-up market sizing with clear methodology documentation.',
		objectiveId: 'obj-002', bountyId: 'bounty-001', assigneeId: 'sol-005',
		status: 'submitted', priority: 'high', rewardVgrd: 5000,
		deadline: '2025-02-20T00:00:00Z', submissionHash: 'QmY8c3...def456',
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-26T00:00:00Z'
	},
	{
		id: 'task-006', title: 'Competitive landscape matrix', description: 'Map 15+ competitors on key dimensions: market share, product capability, geographic reach, funding, and technology stack.',
		objectiveId: 'obj-002', bountyId: 'bounty-001', assigneeId: 'sol-005',
		status: 'submitted', priority: 'high', rewardVgrd: 5000,
		deadline: '2025-03-01T00:00:00Z', submissionHash: 'QmZ9d4...ghi789',
		createdAt: '2025-01-12T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z'
	},
	{
		id: 'task-007', title: 'Industry trends report', description: 'Research and document key industry trends, regulatory landscape, and macro factors affecting the sector.',
		objectiveId: 'obj-002', bountyId: 'bounty-001', assigneeId: 'sol-006',
		status: 'submitted', priority: 'medium', rewardVgrd: 4000,
		deadline: '2025-03-10T00:00:00Z', submissionHash: 'QmA0e5...jkl012',
		createdAt: '2025-01-13T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z'
	},
	// obj-003 tasks (Valuation)
	{
		id: 'task-008', title: 'Public comps screening', description: 'Screen and select 20+ public comparable companies. Document selection criteria and rationale.',
		objectiveId: 'obj-003', bountyId: 'bounty-001', assigneeId: 'sol-007',
		status: 'approved', priority: 'high', rewardVgrd: 4000,
		deadline: '2025-02-28T00:00:00Z', submissionHash: 'QmB1f6...mno345',
		createdAt: '2025-01-14T00:00:00Z', updatedAt: '2025-01-22T00:00:00Z'
	},
	{
		id: 'task-009', title: 'Trading multiples analysis', description: 'Calculate and analyze EV/Revenue, EV/EBITDA, P/E multiples across comp set. Include statistical analysis (mean, median, percentiles).',
		objectiveId: 'obj-003', bountyId: 'bounty-001', assigneeId: 'sol-008',
		status: 'in_progress', priority: 'high', rewardVgrd: 5000,
		deadline: '2025-03-30T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-14T00:00:00Z', updatedAt: '2025-01-28T00:00:00Z'
	},
	// obj-004 tasks (Token Distribution)
	{
		id: 'task-010', title: 'Token holder mapping', description: 'Map top 100 token holders, categorize by type (team, investor, protocol, retail), and assess concentration risk.',
		objectiveId: 'obj-004', bountyId: 'bounty-002', assigneeId: null,
		status: 'todo', priority: 'high', rewardVgrd: 7500,
		deadline: '2025-06-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z'
	},
	{
		id: 'task-011', title: 'Vesting schedule impact model', description: 'Model token unlock schedule and projected selling pressure. Include scenario analysis for different market conditions.',
		objectiveId: 'obj-004', bountyId: 'bounty-002', assigneeId: null,
		status: 'todo', priority: 'medium', rewardVgrd: 7500,
		deadline: '2025-07-01T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z'
	},
	{
		id: 'task-012', title: 'Governance participation analysis', description: 'Analyze historical governance participation rates, voter turnout, and proposal outcomes. Benchmark against comparable DAOs.',
		objectiveId: 'obj-005', bountyId: 'bounty-002', assigneeId: null,
		status: 'todo', priority: 'medium', rewardVgrd: 8000,
		deadline: '2025-07-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-20T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z'
	},
	// ── Academy Tasks (Course Assignments) ─────────────────────────
	// Analyst Bootcamp — Module 1 (completed)
	{
		id: 'task-acad-001', title: 'Build income statement from 10-K', description: 'Extract and model a full income statement from a public company 10-K filing.',
		objectiveId: 'obj-acad-001', bountyId: 'bounty-acad-001', assigneeId: 'sol-004',
		status: 'approved', priority: 'medium', rewardVgrd: 2500,
		deadline: '2025-02-15T00:00:00Z', submissionHash: 'QmAcad1...model',
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-18T00:00:00Z'
	},
	{
		id: 'task-acad-002', title: 'Link balance sheet and cash flow', description: 'Complete the 3-statement linkage: BS fed by IS, CFS reconciling cash.',
		objectiveId: 'obj-acad-001', bountyId: 'bounty-acad-001', assigneeId: 'sol-004',
		status: 'approved', priority: 'medium', rewardVgrd: 2500,
		deadline: '2025-02-25T00:00:00Z', submissionHash: 'QmAcad2...link',
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-20T00:00:00Z'
	},
	// Analyst Bootcamp — Module 2 (in progress)
	{
		id: 'task-acad-003', title: 'Calculate WACC for sample company', description: 'Determine cost of equity (CAPM), cost of debt, and blended WACC with proper weighting.',
		objectiveId: 'obj-acad-002', bountyId: 'bounty-acad-001', assigneeId: 'sol-006',
		status: 'in_progress', priority: 'high', rewardVgrd: 2500,
		deadline: '2025-03-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-27T00:00:00Z'
	},
	{
		id: 'task-acad-004', title: 'Build 5-year DCF with terminal value', description: 'Project free cash flows, discount at WACC, calculate terminal value using exit multiple and perpetuity growth methods.',
		objectiveId: 'obj-acad-002', bountyId: 'bounty-acad-001', assigneeId: 'sol-006',
		status: 'todo', priority: 'high', rewardVgrd: 2500,
		deadline: '2025-04-01T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-05T00:00:00Z'
	},
	// Analyst Bootcamp — Module 3 (not started)
	{
		id: 'task-acad-005', title: 'Screen and select 10 comparable companies', description: 'Define screening criteria, select comps, and document rationale for inclusion/exclusion.',
		objectiveId: 'obj-acad-003', bountyId: 'bounty-acad-001', assigneeId: 'sol-008',
		status: 'todo', priority: 'medium', rewardVgrd: 3000,
		deadline: '2025-05-01T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-05T00:00:00Z', updatedAt: '2025-01-05T00:00:00Z'
	},
	// Associate Track — Module 1 (in progress)
	{
		id: 'task-acad-006', title: 'Write target screening memo', description: 'Draft a 2-page screening memo for a hypothetical acquisition target including thesis, key metrics, and risks.',
		objectiveId: 'obj-acad-004', bountyId: 'bounty-acad-002', assigneeId: 'sol-005',
		status: 'submitted', priority: 'high', rewardVgrd: 5000,
		deadline: '2025-03-30T00:00:00Z', submissionHash: 'QmAcad6...memo',
		createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-25T00:00:00Z'
	},
	{
		id: 'task-acad-007', title: 'Build deal pipeline tracker', description: 'Create a deal pipeline spreadsheet with stages, probability weighting, and expected values.',
		objectiveId: 'obj-acad-004', bountyId: 'bounty-acad-002', assigneeId: 'sol-005',
		status: 'in_progress', priority: 'medium', rewardVgrd: 5000,
		deadline: '2025-04-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-26T00:00:00Z'
	},
	// Associate Track — Module 2 (not started)
	{
		id: 'task-acad-008', title: 'Build DD checklist template', description: 'Create a comprehensive due diligence checklist covering financial, legal, operational, and tech categories.',
		objectiveId: 'obj-acad-005', bountyId: 'bounty-acad-002', assigneeId: null,
		status: 'todo', priority: 'medium', rewardVgrd: 6000,
		deadline: '2025-06-15T00:00:00Z', submissionHash: null,
		createdAt: '2025-01-08T00:00:00Z', updatedAt: '2025-01-08T00:00:00Z'
	}
];

// ── Activity Feed ──────────────────────────────────────────────
export const MOCK_ACTIVITIES: Activity[] = [
	{
		id: 'act-001', type: 'task_submitted', actorId: 'sol-006', actorCallsign: 'RAVEN',
		targetId: 'task-007', targetTitle: 'Industry trends report',
		description: 'submitted work on', timestamp: '2025-01-27T16:45:00Z', metadata: { bountyTitle: 'Series B Due Diligence — TechCorp Acquisition' }
	},
	{
		id: 'act-002', type: 'task_submitted', actorId: 'sol-005', actorCallsign: 'SPECTER',
		targetId: 'task-006', targetTitle: 'Competitive landscape matrix',
		description: 'submitted work on', timestamp: '2025-01-27T14:20:00Z', metadata: { bountyTitle: 'Series B Due Diligence — TechCorp Acquisition' }
	},
	{
		id: 'act-003', type: 'objective_opened', actorId: 'sol-002', actorCallsign: 'NIGHTHAWK',
		targetId: 'obj-002', targetTitle: 'Market & Competitive Analysis',
		description: 'moved to review', timestamp: '2025-01-27T11:00:00Z', metadata: { bountyTitle: 'Series B Due Diligence — TechCorp Acquisition' }
	},
	{
		id: 'act-004', type: 'task_completed', actorId: 'sol-007', actorCallsign: 'WRAITH',
		targetId: 'task-008', targetTitle: 'Public comps screening',
		description: 'completed', timestamp: '2025-01-22T09:30:00Z', metadata: { reward: 4000 }
	},
	{
		id: 'act-005', type: 'bounty_created', actorId: 'sol-001', actorCallsign: 'IRONFORGE',
		targetId: 'bounty-004', targetTitle: 'Cross-Chain Bridge Security Assessment',
		description: 'created bounty', timestamp: '2025-01-28T08:00:00Z', metadata: { amount: 40000 }
	},
	{
		id: 'act-006', type: 'soldier_promoted', actorId: 'sol-001', actorCallsign: 'IRONFORGE',
		targetId: 'sol-005', targetTitle: 'SPECTER',
		description: 'promoted to CPL', timestamp: '2025-01-21T15:00:00Z', metadata: { newRank: 'CPL' }
	},
	{
		id: 'act-007', type: 'bounty_created', actorId: 'sol-001', actorCallsign: 'IRONFORGE',
		targetId: 'bounty-002', targetTitle: 'DeFi Protocol Tokenomics Audit',
		description: 'created bounty', timestamp: '2025-01-20T10:00:00Z', metadata: { amount: 30000 }
	},
	{
		id: 'act-008', type: 'task_completed', actorId: 'sol-003', actorCallsign: 'VIPER',
		targetId: 'task-001', targetTitle: 'Revenue build-up model',
		description: 'completed', timestamp: '2025-01-24T17:00:00Z', metadata: { reward: 5000 }
	}
];

// Current user (for demo purposes - simulates logged-in soldier)
export const CURRENT_USER_ID = 'sol-004';

// Helper: get soldier by ID
export function getSoldier(id: string): Soldier | undefined {
	return MOCK_SOLDIERS.find(s => s.id === id);
}

// Helper: get bounty objectives
export function getBountyObjectives(bountyId: string): Objective[] {
	return MOCK_OBJECTIVES.filter(o => o.bountyId === bountyId);
}

// Helper: get objective tasks
export function getObjectiveTasks(objectiveId: string): Task[] {
	return MOCK_TASKS.filter(t => t.objectiveId === objectiveId);
}

// Helper: get tasks assigned to a soldier
export function getSoldierTasks(soldierId: string): Task[] {
	return MOCK_TASKS.filter(t => t.assigneeId === soldierId);
}

// Helper: get unit by ID
export function getUnit(id: string): Unit | undefined {
	return MOCK_UNITS.find(u => u.id === id);
}
