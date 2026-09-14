# code — practices every stack shares

> Load when: any change to source code. Last watch: —

## MUST

- Return an empty collection when there is nothing to return, never `null` / `None` / `undefined` — every caller would otherwise test for absence before iterating, and the one that forgets fails far from the cause
- Keep existing input validation, error handling and accessibility attributes intact in code you touch — their removal breaks no test and only shows in production, on the user they protected

## NEVER

- Never catch everything (`catch (Exception e)`, `catch (e)` without rethrow, bare `except:`) to make a failure disappear — it also catches what you cannot handle, including the programming errors you wanted to see
- Never swallow an exception: log it with its stack trace or rethrow it — a log without the trace erases the only information that led back to the cause

## Not here

- Syntax a framework imposes → its techno file
