# Taverinn - Testing Checklist

## Smoke Test

- [ ] App opens
- [ ] Login screen appears
- [ ] Register works
- [ ] Login works
- [ ] Home loads
- [ ] Games load from Supabase
- [ ] Create LFG works
- [ ] LFG appears on Home
- [ ] Filter works
- [ ] Join Party works
- [ ] My Party shows joined party
- [ ] Profile loads
- [ ] Add Game Dashboard works
- [ ] Logout works

## Browser

Test on Chrome:
- [ ] 1280px desktop
- [ ] narrow browser width
- [ ] refresh
- [ ] invalid form
- [ ] network error handling

## Android

- [ ] Login
- [ ] Scroll
- [ ] Keyboard does not hide required fields unexpectedly
- [ ] Create LFG
- [ ] Filter bottom sheets
- [ ] Join party
- [ ] Back navigation
- [ ] Logout

## Suggested test cases

| ID | Scenario | Expected |
|---|---|---|
| TC-001 | Register valid account | Account created |
| TC-002 | Register duplicate email | Error shown |
| TC-003 | Login valid | Home displayed |
| TC-004 | Wrong password | Error shown |
| TC-005 | Create valid LFG | Post saved |
| TC-006 | Create LFG without rank | Validation shown |
| TC-007 | Filter by game | Matching posts only |
| TC-008 | Filter by rank | Matching posts only |
| TC-009 | Join open party | Player count increases |
| TC-010 | Join same party twice | Error shown |
| TC-011 | Join full party | Error shown |
| TC-012 | Add game dashboard | Game saved |
| TC-013 | Win rate > 100 | Validation shown |
| TC-014 | Logout | Login screen displayed |
