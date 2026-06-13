function copyCode(elementId, btn) {
    const codeElement = document.getElementById(elementId);
    if (!codeElement) return;

    // Get the raw text content without HTML tags
    const textToCopy = codeElement.innerText;

    navigator.clipboard.writeText(textToCopy).then(() => {
        // Change button state
        const originalHTML = btn.innerHTML;
        
        btn.innerHTML = `
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            <span>Copied!</span>
        `;
        btn.classList.add('success');

        // Revert after 2 seconds
        setTimeout(() => {
            btn.innerHTML = originalHTML;
            btn.classList.remove('success');
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy: ', err);
    });
}
