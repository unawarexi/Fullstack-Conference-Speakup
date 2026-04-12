[browser] Uncaught Error: Hydration failed because the server rendered HTML didn't match the client. As a result this tree will be regenerated on the client. This can happen if a SSR-ed Client Component used:

- A server/client branch `if (typeof window !== 'undefined')`.
- Variable input such as `Date.now()` or `Math.random()` which changes each time it's called.
- Date formatting in a user's locale which doesn't match the server.
- External changing data without sending a snapshot of it along with the HTML.
- Invalid HTML tag nesting.

It can also happen if the client has a browser extension installed which messes with the HTML before React loaded.

https://react.dev/link/hydration-mismatch

  ...
    <LandingHeader>
      <header className="fixed top-...">
        <div className="mx-auto fl...">
          <LinkComponent>
          <nav>
          <div className="hidden md:...">
            <button onClick={function toggleDarkMode} aria-label="Toggle theme" className="flex h-10 ...">
              <AnimatePresence mode="wait" initial={false}>
                <PresenceChild isPresent={true} initial={false} custom={undefined} presenceAffectsLayout={true} ...>
                  <PopChild pop={false} isPresent={true} anchorX="left" anchorY="top" root={undefined}>
                    <PopChildMeasure isPresent={true} childRef={{current:null}} sizeRef={{...}} pop={false}>
                      <motion.div initial={{scale:0,rotate:-90}} animate={{scale:1,rotate:0}} exit={{scale:0,rotate:90}} ...>
                        <div style={{...}} ref={function useMotionRef.useCallback}>
                          <Sun className="h-5 w-5">
                            <svg
                              ref={null}
                              xmlns="http://www.w3.org/2000/svg"
                              width={24}
                              height={24}
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth={2}
                              strokeLinecap="round"
                              strokeLinejoin="round"
+                             className="lucide lucide-sun h-5 w-5"
-                             className="lucide lucide-moon h-5 w-5"
                              aria-hidden="true"
                            >
+                             <circle cx="12" cy="12" r="4">
-                             <path
-                               d="M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268..."
-                             >
                              ...
            ...
          ...
      ...

    at <unknown> (https://react.dev/link/hydration-mismatch)
    at circle (<anonymous>)
    at Array.map (<anonymous>)
    at LandingHeader (src/app/(landing)/layout.tsx:91:21)
    at LandingLayout (src/app/(landing)/layout.tsx:341:7)
  89 |                     transition={{ duration: 0.2 }}
  90 |                   >
> 91 |                     <Sun className="h-5 w-5" />
     |                     ^
  92 |                   </motion.div>
  93 |                 ) : (
  94 |                   <motion.div
[browser] Image with src "/logo/emblem.png" has either width or height modified, but not the other. If you use CSS to change the size of your image, also include the styles 'width: "auto"' or 'height: "auto"' to maintain the aspect ratio.
[browser] Image with src "/logo/logo.png" has either width or height modified, but not the other. If you use CSS to change the size of your image, also include the styles 'width: "auto"' or 'height: "auto"' to maintain the aspect ratio.
[browser] Please ensure that the container has a non-static position, like 'relative', 'fixed', or 'absolute' to ensure scroll offset is calculated correctly. (<anonymous>)
[browser] THREE.THREE.Clock: This module has been deprecated. Please use THREE.Timer instead.
