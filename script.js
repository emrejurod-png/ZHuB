// Boot Loader Logic
document.addEventListener('DOMContentLoaded', () => {
    const bootScreen = document.getElementById('boot-screen');
    const mainApp = document.getElementById('main-app');
    const loadingBar = document.getElementById('loadingBar');
    const loadingText = document.getElementById('loadingText');

    let progress = 0;
    
    // Fake loading steps
    const steps = [
        { progress: 20, text: "Connecting to secure servers..." },
        { progress: 45, text: "Verifying client integrity..." },
        { progress: 75, text: "Fetching latest offsets..." },
        { progress: 100, text: "Environment ready." }
    ];

    let currentStep = 0;

    const interval = setInterval(() => {
        if (currentStep < steps.length) {
            progress = steps[currentStep].progress;
            loadingBar.style.width = `${progress}%`;
            loadingText.innerText = steps[currentStep].text;
            currentStep++;
        } else {
            clearInterval(interval);
            setTimeout(() => {
                bootScreen.style.opacity = '0';
                setTimeout(() => {
                    bootScreen.classList.add('hidden');
                    mainApp.classList.remove('hidden');
                }, 500); // Wait for fade out
            }, 500); // Wait a bit at 100%
        }
    }, 600); // Time between steps
});

// Tab Switching Logic
function switchTab(tabId) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.add('hidden');
        tab.classList.remove('active');
    });

    // Remove active class from all nav items
    document.querySelectorAll('.nav-item').forEach(btn => {
        btn.classList.remove('active');
    });

    // Show selected tab
    document.getElementById(`tab-${tabId}`).classList.remove('hidden');
    document.getElementById(`tab-${tabId}`).classList.add('active');

    // Highlight selected button (finding it based on onclick attribute is a quick way)
    const btn = document.querySelector(`button[onclick="switchTab('${tabId}')"]`);
    if(btn) btn.classList.add('active');
}

// Copy Logic
function copyScript() {
    const codeElement = document.getElementById('scriptText');
    const btn = document.getElementById('copyBtn');
    if (!codeElement) return;

    const textToCopy = codeElement.innerText;

    navigator.clipboard.writeText(textToCopy).then(() => {
        const originalHTML = btn.innerHTML;
        
        btn.innerHTML = `
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Copied!
        `;
        btn.classList.add('success');

        setTimeout(() => {
            btn.innerHTML = originalHTML;
            btn.classList.remove('success');
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy: ', err);
    });
}
