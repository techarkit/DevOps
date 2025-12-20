The **recommended way to write a pull request (PR) description** is to follow a **clear, structured template** so reviewers can quickly understand:

- What the change does
- Why it's needed
- How it's implemented
- Whether it closes/fixes any issues

---

## ✅ Recommended PR Description Template

```markdown
## Summary

Briefly describe what this PR does.  
Keep it short and to the point.

## Related Issues

Closes #123  
Fixes #456

## Changes Made

- Describe major changes or additions
- List key files/components modified
- Mention any refactoring or cleanup

## How to Test

Steps the reviewer can follow to test the changes.

1. ...
2. ...
3. ...

## Screenshots (if applicable)

[Add screenshots/GIFs for UI changes or visual output]

## Notes

- Mention any caveats, TODOs, or things to review carefully
- Mention backward compatibility or breaking changes
```

---

## 🧪 Example PR Description

```markdown
## Summary

This PR implements a fix for the login timeout issue in the authentication module.  
It also adds unit tests for the session manager.

## Related Issues

Fixes #42

## Changes Made

- Updated `auth/session.py` to use a sliding timeout window
- Added tests in `tests/test_session.py`
- Refactored `validate_user()` to support optional MFA

## How to Test

1. Run `pytest`
2. Manually test login on `localhost:8000`
3. Ensure session remains active with periodic API calls

## Screenshots

_No visual changes._

## Notes

- This introduces a minor change in session logic. Please review thoroughly.
```

---

You can also add **checklists** for reviewers or your own WIP tracking:

```markdown
## Checklist

- [x] Code compiles and passes lint
- [x] All tests pass
- [ ] Documentation updated
```

---

Let me know if you want a reusable PR template (`PULL_REQUEST_TEMPLATE.md`) for your repository!
