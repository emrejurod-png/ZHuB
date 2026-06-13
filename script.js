function copyScript() {
    const codeElement = document.getElementById('scriptText');
    const btn = document.getElementById('copyBtn');
    if (!codeElement) return;

    const textToCopy = codeElement.innerText;

    navigator.clipboard.writeText(textToCopy).then(() => {
        const originalText = btn.innerText;
        
        btn.innerText = 'Copied';
        btn.classList.add('success');

        setTimeout(() => {
            btn.innerText = originalText;
            btn.classList.remove('success');
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy: ', err);
    });
}
