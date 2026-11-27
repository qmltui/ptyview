/** @param {Runner} app */
function main(app) {
    app.waitForText("[RUNNING]", 5000);
    app.expectText("PID:");

    // Send command through the input bar and verify shell output renders inside PtyView.
    app.press("Enter");
    app.waitForText("Sent: echo 'Hello from PtyView!'", 5000);
    app.item("shellView").waitForText("Hello from PtyView!", { timeout: 5000 });

    // Focus PtyView directly and type a command containing 'q' whose output differs from
    // the typed text: proves the root 'Q' Shortcut is suppressed and the shell ran it.
    app.item("shellView").click();
    app.typeText("printf 'q_%s\\n' ok");
    app.press("Enter");
    app.item("shellView").waitForText("q_ok", { timeout: 5000 });
    app.captureText("hello_ptyview.txt");

    // Escape exits cleanly through the BeforeItem handler.
    app.press("Escape");
}
