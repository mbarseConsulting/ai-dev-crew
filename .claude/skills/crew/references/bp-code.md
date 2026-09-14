# code — practices every stack shares

> Chargé pour tout changement de code source. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.
>
> Dernière passe de veille : —

## Règles

### What you MUST do

- Return an empty collection when there is nothing to return, never `null` / `None` / `undefined`
- Keep existing input validation, error handling and accessibility (attributes, keyboard handling) intact in any code you touch

### What you NEVER do

- Never catch every exception at once (`catch (Exception e)`, `catch (e)` with no rethrow, bare `except:`) to make a failure disappear
- Never swallow an exception: log it with its stack trace, or rethrow it
- Do NOT use these rules for the syntax a framework imposes — that is its techno file

### En un coup d'oeil

- Empty, not absent
- What was protected stays protected
- Failures stay visible

---

## Pourquoi

**Une collection vide, jamais `null`.** Chaque appelant doit sinon tester l'absence avant de parcourir — et celui qui oublie produit une erreur loin de sa cause. Une collection vide se parcourt sans cas particulier.

**Ce qui protégeait continue de protéger.** Une validation, une gestion d'erreur ou un attribut d'accessibilité retirés en passant ne cassent aucun test : leur absence ne se voit qu'en production, chez l'utilisateur qu'ils protégeaient.

**Un `catch` global attrape aussi ce qu'on ne sait pas traiter**, y compris les erreurs de programmation qu'on voulait voir remonter. Un `catch` qui ne journalise pas la trace efface la seule information qui permettait de retrouver la cause.
