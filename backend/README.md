# Vanguard Backend - Firebase

## Project Info
- **Project ID**: vanguard-dao
- **Project Number**: 27346039636

## Emulator Ports
| Service | Port |
|---------|------|
| Auth | 9099 |
| Functions | 5001 |
| Firestore | 8080 |
| Emulator UI | 4000 |

## Quick Start

```powershell
cd backend/functions
npm install
npm run build
cd ..
firebase emulators:start
```

## Seed Data
Once emulators running (use curl or PowerShell):

**Using curl (Git Bash / WSL):**
```bash
curl -X POST -H "Content-Type: application/json" -d '{"data":{}}' http://127.0.0.1:5001/vanguard-dao/us-central1/seedCallsignWords
curl -X POST -H "Content-Type: application/json" -d '{"data":{}}' http://127.0.0.1:5001/vanguard-dao/us-central1/seedDemoData
```

**Using PowerShell:**
```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:5001/vanguard-dao/us-central1/seedCallsignWords" -Method POST -ContentType "application/json" -Body '{"data":{}}'
Invoke-RestMethod -Uri "http://127.0.0.1:5001/vanguard-dao/us-central1/seedDemoData" -Method POST -ContentType "application/json" -Body '{"data":{}}'
```

## Shutdown Emulators

**Graceful shutdown (Ctrl+C in terminal running emulators)**

**Force shutdown (if ports are stuck):**
```powershell
# Stop Java processes (Firestore emulator)
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue

# Or kill by port
Get-NetTCPConnection -LocalPort 8080,9099,5001 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
```

## Cloud Functions

| Function | Type | Description |
|----------|------|-------------|
| `quickStart` | callable | Anonymous auth + create soldier + join default squad |
| `enlistSoldier` | callable | Enlist with wallet + squad selection |
| `generateCallsign` | callable | Generate unique callsign |
| `promoteSoldier` | callable | Promote soldier (authority matrix enforced) |
| `canPromote` | callable | Check if promotion allowed |
| `splitSquad` | callable | Split squad at 11 members (CPT only) |
| `checkSplitThreshold` | trigger | Firestore trigger on unit updates |
| `reviewApplication` | callable | Accept/reject squad application |
| `seedCallsignWords` | callable | Seed callsign word lists |
| `seedDemoData` | callable | Seed demo units/soldiers/bounties |

## Collections
- `soldiers` - User profiles with rank, callsign, stats
- `units` - Squads, sections, platoons, companies
- `chatChannels` - Chat channels per unit
- `bounties` - Task bounties
- `promotions` - Promotion audit log
- `squadApplications` - Join requests
- `callsignWords` - Prefix/suffix for callsigns

## Cloud Deployment

### Deploy to Firebase Cloud
```powershell
cd backend
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy  # Deploy everything
```

### Cloud URLs
After deployment, functions are available at:
```
https://us-central1-vanguard-dao.cloudfunctions.net/<functionName>
```

### View Cloud Logs
```powershell
# View all function logs
firebase functions:log

# View logs for specific function
firebase functions:log --only quickStart

# Stream logs in real-time
firebase functions:log --follow

# View logs from Firebase Console
# https://console.firebase.google.com/project/vanguard-dao/functions/logs
```

### View Firestore Data (Cloud)
- Firebase Console: https://console.firebase.google.com/project/vanguard-dao/firestore

## Local Development

### View Emulator Logs
- **Emulator UI**: http://127.0.0.1:4000 (when emulators are running)
- **Firestore Data**: http://127.0.0.1:4000/firestore
- **Auth Users**: http://127.0.0.1:4000/auth
- **Function Logs**: Displayed in terminal running emulators

### Local vs Cloud
| Aspect | Local (Emulators) | Cloud |
|--------|-------------------|-------|
| URL | `127.0.0.1:5001/vanguard-dao/us-central1/` | `us-central1-vanguard-dao.cloudfunctions.net/` |
| Data | Ephemeral (reset on restart) | Persistent |
| Auth | Mock auth | Real Firebase Auth |
| Cost | Free | Pay-as-you-go |

## Troubleshooting

**Port taken error:**
```powershell
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
firebase emulators:start
```

**Rebuild functions:**
```powershell
cd backend/functions
npm run build
```

**View Emulator UI:**
Open http://127.0.0.1:4000 in browser
