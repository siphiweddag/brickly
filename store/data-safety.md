# Google Play Data Safety working declaration

## Current shipped behavior

- No user account.
- No advertising SDK.
- No analytics SDK.
- No crash-reporting SDK.
- No backend or remote database.
- No personal information requested.
- No app permissions requested beyond platform-default Flutter behavior.
- High score, settings, selected themes, tutorial state, unlocked levels, and stars are stored locally using `shared_preferences`.
- The app opens Stratida web, privacy, terms, and email destinations only after a user taps the relevant link.

## Suggested Play Console answers

- Does the app collect or share required user data? **No**
- Is all user data encrypted in transit? **Not applicable; the app does not transmit user data**
- Can users request data deletion? **Not applicable to developer-held data; users can reset game progress in Settings or clear/uninstall the app**
- Privacy policy: `https://stratida.com/privacy-policy/`

## Accuracy gate

Re-review this declaration before every release. Adding analytics, advertising, crash reporting, cloud saves, accounts, support forms, or other SDKs can change the required answers. Google Play makes the developer responsible for accurate declarations, including third-party SDK behavior.
