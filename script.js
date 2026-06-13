// ZHuB — Script
// Minimal JS: copy button + scroll fade-in

function copyScript() {
    const code = document.getElementById('scriptCode').textContent;
    const btn = document.getElementById('copyBtn');
    const copyIcon = btn.querySelector('.copy-icon');
    const checkIcon = btn.querySelector('.check-icon');
    const copyText = btn.querySelector('.copy-text');

    navigator.clipboard.writeText(code).then(() => {
        btn.classList.add('copied');
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';
        copyText.textContent = 'Copied';

        setTimeout(() => {
            btn.classList.remove('copied');
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            copyText.textContent = 'Copy';
        }, 2000);
    }).catch(() => {
        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = code;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);

        btn.classList.add('copied');
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';
        copyText.textContent = 'Copied';

        setTimeout(() => {
            btn.classList.remove('copied');
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            copyText.textContent = 'Copy';
        }, 2000);
    });
}

// Fade-in on scroll
document.addEventListener('DOMContentLoaded', () => {
    const targets = document.querySelectorAll(
        '.feature-card, .script-block, .info-box, .section-header'
    );

    targets.forEach(el => el.classList.add('fade-in'));

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -40px 0px'
    });

    targets.forEach(el => observer.observe(el));
});
