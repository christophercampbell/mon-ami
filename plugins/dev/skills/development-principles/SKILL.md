---
name: development-principles
description: Use when designing, implementing, or reviewing code - applies pragmatic engineering principles (YAGNI, SOLID, KISS, etc.)
---

# Development Principles

Apply these principles when designing, implementing, or reviewing code.

## YAGNI (You Aren't Gonna Need It)

**Core Philosophy:** Implement only what is explicitly required for current, concrete needs.

### Guidelines
- Implement only what is explicitly required for current needs
- Avoid speculative features - don't add code for "what if" scenarios
- Prefer simple, direct solutions over complex abstractions
- Choose less code over more code unless there's a proven need
- Don't future-proof - solve today's problems, not tomorrow's hypothetical ones

### Red Flags
- Adding support for multiple scenarios when only one exists
- Creating extensible frameworks for single use cases
- Building configuration systems for unused options
- Implementing generic handlers when specific solutions work
- Adding abstraction layers "for future flexibility"

### Green Flags
- Hard-coding values that are actually constant
- Duplicating code if use cases might diverge
- Direct, obvious implementations
- Specific solutions that solve the immediate problem

### When to Add Abstractions
Only when you have:
1. At least 2-3 concrete use cases that need it
2. Clear evidence it reduces overall complexity
3. Current, real problems it solves (not hypothetical)

### Decision Framework
1. "Is this solving a problem we have right now?"
2. "Is the simpler solution insufficient for current requirements?"
3. "Can we wait until we have more information?"

If #1 is "no", stop and reconsider.

---

## Composability

**Principle:** Prefer composable commands and tools over monolithic solutions.

### Guidelines
- **Single Responsibility** - Each command/function has one clear responsibility
- **Composable by Design** - Commands can be combined in flexible ways
- **Explicit Steps** - Avoid hidden orchestration; make each step visible
- **Clear Prerequisites** - Provide prerequisite checks with helpful error messages
- **Operator Choice** - Let operators choose their tools
- **Simplicity Over Automation** - Prefer simplicity when it improves clarity

### Good Pattern (Composable)
```bash
make build-docker-local
quake -f scenario.toml setup
quake start
quake load --rate 1000 --time 60
quake upgrade --validator-index 0
```

### Anti-Pattern (Monolithic)
```bash
quake upgrade --do-everything --with-all-the-options
```

### Benefits
- Easier debugging - isolate and test each step independently
- More flexible - substitute your own tools
- Clearer intent - commands show what's happening
- Better error messages - specific prerequisite guidance
- Simpler code - less orchestration complexity

---

## SOLID Principles

### Single Responsibility Principle (SRP)
**Principle:** A module/class should have one, and only one, reason to change.

**Guidelines:**
- Each component does one thing well
- Changes to business logic shouldn't require changing infrastructure code
- Separate concerns: data access, business logic, presentation
- Functions should be small and focused on a single task

**Red Flags:**
- Classes with names like `Manager`, `Handler`, `Utility` that do multiple things
- Functions that do "and also" operations
- Modules that import from many unrelated areas

### Open/Closed Principle (OCP)
**Principle:** Software entities should be open for extension, closed for modification.

**Guidelines:**
- Use composition and dependency injection over modification
- Design interfaces that can be extended without changing existing code
- But: Apply only when you have 2-3 concrete cases (avoid YAGNI violations)

**Balance:**
- Don't create abstractions prematurely
- When extending, prefer adding new code over modifying working code
- Refactor to OCP when you have evidence it's needed

### Liskov Substitution Principle (LSP)
**Principle:** Subtypes must be substitutable for their base types.

**Guidelines:**
- Derived types should strengthen, not weaken, contracts
- Don't throw unexpected errors in implementations
- Maintain behavioral consistency across implementations

### Interface Segregation Principle (ISP)
**Principle:** Clients shouldn't depend on interfaces they don't use.

**Guidelines:**
- Small, focused traits/interfaces over large ones
- Split large interfaces into smaller, cohesive ones
- Avoid "fat" interfaces with methods clients must stub out

**Example:**
```rust
// Good: Focused traits
trait Read { fn read(&self) -> Result<Data>; }
trait Write { fn write(&self, data: Data) -> Result<()>; }

// Bad: Fat interface
trait Storage { fn read(&self) -> Result<Data>; fn write(&self, data: Data) -> Result<()>; }
```

### Dependency Inversion Principle (DIP)
**Principle:** Depend on abstractions, not concretions.

**Guidelines:**
- High-level modules shouldn't depend on low-level modules
- Both should depend on abstractions (traits/interfaces)
- But: Only introduce abstractions when you have 2-3 concrete implementations (balance with YAGNI)

---

## DRY vs Duplication

**Core Philosophy:** Don't Repeat Yourself, but duplication is sometimes better than the wrong abstraction.

### When to DRY
- Identical business logic in multiple places
- Same algorithm with minor variations
- Configuration or constants used across modules
- Error messages and validation rules

### When Duplication is OK
- Use cases that are similar now but likely to diverge
- Code in different domains that happens to look similar
- Early exploration phase - wait to see the pattern
- Abstraction would be more complex than duplication

### The Rule of Three
Wait until you have 3 instances before abstracting. Two instances might be coincidence.

**Red Flags of Wrong Abstractions:**
- Parameters that are always the same for each caller
- Boolean flags to control behavior
- Abstractions that are only used in one place
- "Framework" code for 1-2 use cases

---

## KISS (Keep It Simple, Stupid)

**Core Philosophy:** Simple solutions are better than clever ones.

### Guidelines
- Prefer boring, well-understood patterns
- Choose clarity over cleverness
- Use standard library solutions when available
- Avoid language tricks that require explanation

### Red Flags
- Overly generic code that's hard to understand
- Complex type hierarchies
- Clever bit manipulation without clear benefit
- Nested abstractions that obscure intent

### Green Flags
- Code that reads like prose
- Obvious implementation
- Minimal indirection
- Self-documenting variable names

---

## Separation of Concerns

**Principle:** Organize code by responsibility, keep concerns isolated.

### Guidelines
- Business logic separate from infrastructure
- Data access layer separate from business rules
- API/interface separate from implementation
- Test code separate from production code

### Layers
1. **Domain/Business Logic** - Core rules, pure functions
2. **Application Layer** - Orchestration, use cases
3. **Infrastructure** - Database, network, file system
4. **Presentation** - CLI, API, UI

**Benefits:**
- Easier to test each layer independently
- Can replace infrastructure without changing business logic
- Clear boundaries reduce coupling

---

## Fail Fast

**Principle:** Detect and report errors as early as possible.

### Guidelines
- Validate inputs at system boundaries
- Use type systems to make invalid states unrepresentable
- Prefer compile-time errors over runtime errors
- Return early on error conditions
- Don't let errors propagate silently

### Error Detection Hierarchy (Best to Worst)
1. Compile-time type errors
2. Startup validation (fail before processing)
3. Input validation at boundaries
4. Runtime checks during processing
5. Silent failures or logged warnings

**Example:**
```rust
// Good: Fail fast with clear error
fn process(value: u32) -> Result<Output> {
    if value == 0 {
        return Err(Error::InvalidInput("value cannot be zero"));
    }
    // ... rest of processing
}

// Bad: Silent failure
fn process(value: u32) -> Option<Output> {
    if value == 0 {
        return None; // Why did it fail?
    }
    // ...
}
```

---

## Error Handling

**Philosophy:** Errors are data, handle them explicitly.

### Guidelines
- Use `Result<T, E>` for operations that can fail
- Use custom error types with context
- Chain errors to preserve context (wrap, don't replace)
- Avoid `unwrap()` and `expect()` in production code
- Handle errors at appropriate abstraction levels

### Error Propagation
- **Library code:** Return specific errors, let caller decide handling
- **Application code:** Handle errors appropriately for the context
- **User-facing code:** Translate errors to user-friendly messages

### When to Panic
- Programmer errors (bugs, invariant violations)
- Unrecoverable errors in main() or tests
- Never panic in library code

---

## Testing Philosophy

**Core Philosophy:** Tests give confidence, not just coverage.

### Testing Pyramid
1. **Unit Tests (70%)** - Fast, isolated, test single components
2. **Integration Tests (20%)** - Test component interactions
3. **E2E Tests (10%)** - Test full system behavior

### Guidelines
- Test behavior, not implementation
- Write tests that would catch real bugs
- Prefer testing through public APIs
- Don't mock what you don't own
- Tests should be deterministic and fast

### What to Test
- **Always:** Public APIs, business logic, edge cases, error paths
- **Sometimes:** Complex algorithms, critical paths
- **Rarely:** Trivial getters/setters, generated code

### When to Mock
- External services (APIs, databases)
- Slow operations (network, disk)
- Non-deterministic behavior (time, random)

**Red Flags:**
- Tests that break when refactoring (brittle)
- Tests that test mocks, not real behavior
- Tests that duplicate production code
- 100% coverage as a goal (chase meaningful coverage)

---

## Performance

**Core Philosophy:** Make it work, make it right, make it fast (in that order).

### Guidelines
- Correctness first, performance second
- Measure before optimizing (no premature optimization)
- Profile to find actual bottlenecks
- Optimize the hot path, not everything
- Document performance assumptions and requirements

### When to Optimize
1. Profiler shows it's a bottleneck
2. It fails performance requirements
3. It's preventing users from doing their work
4. You have benchmarks to prove the improvement

### When NOT to Optimize
- "It feels slow" without measurements
- Theoretical performance improvements
- Micro-optimizations in cold code
- Before correctness is established

**Quote:** "Premature optimization is the root of all evil" - Donald Knuth

---

## Security Principles

### Guidelines
- Never trust user input - validate everything
- Use parameterized queries (no SQL injection)
- Don't log sensitive data (passwords, tokens, keys)
- Fail securely (deny by default)
- Keep dependencies updated
- Use secure defaults

### Common Vulnerabilities
- **Injection:** SQL, command, path traversal
- **Authentication:** Weak passwords, session management
- **Authorization:** Privilege escalation, missing checks
- **Sensitive Data:** Exposure in logs, errors, or responses
- **Dependencies:** Known vulnerabilities in libraries

---

## Code Review Standards

### What to Look For
1. **Correctness** - Does it solve the problem?
2. **Design** - Is it well-structured?
3. **Readability** - Can others understand it?
4. **Testing** - Are there adequate tests?
5. **Security** - Are there vulnerabilities?
6. **Performance** - Are there obvious bottlenecks?

### Guidelines
- Be kind and constructive
- Explain the "why" behind suggestions
- Ask questions instead of making demands
- Distinguish between "must fix" and "nice to have"
- Approve when it's good enough (perfect is the enemy of done)

---

## Refactoring Guidelines

**Principle:** Improve code structure without changing behavior.

### When to Refactor
- Code is hard to understand
- Code is hard to change
- You're about to add a feature that's difficult with current structure
- You touch code and see obvious improvements

### When NOT to Refactor
- "Just because" without a specific goal
- Code that rarely changes (if it works, leave it)
- During feature development (refactor OR add features, not both)
- Without tests to verify behavior preservation

### Refactoring Process
1. Ensure good test coverage
2. Make small, incremental changes
3. Run tests after each change
4. Commit frequently
5. Keep refactoring separate from feature work

**Red Flags:**
- Large "refactoring" PRs that change behavior
- Refactoring without tests
- Renaming things without clear benefit
- Introducing abstractions that violate YAGNI

---

## Problem-Solving Approach

### Investigation
- Deep-dive investigation over surface-level fixes
- Understand root causes through code exploration
- Document findings with specific file paths and line numbers

### Technical Preferences
- Sequential, controlled flows over concurrent race conditions
- Pre-validated state before execution
- Clear authentication/authorization patterns
- Fail fast with explicit errors
- Simple, direct implementations

---

## Communication Style

### Clarity
- Concise, actionable information
- Minimal fluff, maximum signal
- Ready-to-use formatted outputs for sharing

### Writing Style
- Apply Strunk & White's *Elements of Style* principles to all prose
- Use active voice
- Omit needless words
- Use definite, specific, concrete language
- Put statements in positive form
- Keep related words together

### Documentation
- Structured markdown with clear sections
- Include technical details (file paths, line numbers, code references)
- Comparison tables for clarity
- Best practices at the end
- No emojis unless explicitly requested

---

## PR Authoring

### Core Principle
Expose **architecture and interface**, not implementation details. Focus on what/why, not how.

### Summary Section
- What problem this solves
- High-level solution approach
- Key commands/interface introduced

### Details Section
**Include:**
- Architecture overview (patterns, key components, design decisions)
- What functionality exists (test groups, commands, features)
- Command interface with examples
- How components interact at a high level

**Exclude:**
- Specific file names or code structure details
- Refactoring metrics (lines saved, functions extracted)
- Low-level implementation choices (helper functions, type aliases, iterator methods vs booleans)
- Function signatures or implementation patterns
- Which specific methods were added to which classes

### Testing Section
- Concise command examples showing usage
- What was verified (not how)

### Documentation Section
- What was documented (sections added, guides provided)
- Not detailed lists of every documentation change

### Style
- Terse, high-level language
- Remove bold markdown in bullet points
- Use plain backticks for inline code
- Use code blocks only in Testing section for command examples
- Architecture-level view that lets reviewers understand design without code-level details
