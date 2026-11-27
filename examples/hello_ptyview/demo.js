/** @param {Runner} app */
function main(app) {
    app.waitForText("[RUNNING]", 5000);
    app.expectText("PID:");
    // Wall-time hold so the child login shell finishes printing its prompt.
    app.sleep(800);

    app.press("Enter");
    app.waitForText("Sent: echo 'Hello from PtyView!'", 5000);
    app.waitForText("Hello from PtyView!", 5000);
    // Wall-time hold so the rendered shell output stays legible in the cast.
    app.sleep(1000);
    app.captureText("pty_view.txt");
    app.stopRecording();
}
