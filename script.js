function copyCode(elementId, btn) {
    const codeElement = document.getElementById(elementId);
    if (!codeElement) return;

    // Get the text to copy
    const textToCopy = codeElement.innerText;

    // Use navigator clipboard API
    navigator.clipboard.writeText(textToCopy).then(() => {
        // Change button text temporarily
        const originalText = btn.innerText;
        btn.innerText = "Copied!";
        btn.style.background = "#4ade80"; // subtle green
        btn.style.color = "#000";

        setTimeout(() => {
            btn.innerText = originalText;
            btn.style.background = "#ffffff";
            btn.style.color = "#000000";
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy text: ', err);
        btn.innerText = "Error";
    });
}
