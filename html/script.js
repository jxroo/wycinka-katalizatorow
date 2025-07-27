window.addEventListener('message', function(event) {
    const item = event.data;
    if (item.type === 'showMinigame') {
        const config = item.config;
        const container = document.querySelector('.minigame-container');
        const counterDiv = document.getElementById('counter');
        const successZone = document.querySelector('.success-zone');
        const marker = document.querySelector('.marker');
        
        let currentHits = 0;
        let gameTimeout;

        // Ustawienia z config.lua
        successZone.style.width = `${config.successZoneWidth}%`;
        marker.style.animationDuration = `${config.markerSpeed}s`;
        
        function randomizeSuccessZone() {
            const maxLeft = 100 - config.successZoneWidth;
            const newLeft = Math.random() * maxLeft;
            successZone.style.left = `${newLeft}%`;
        }

        function updateCounter() {
            counterDiv.innerHTML = `Trafienia: <strong>${currentHits} / ${config.requiredHits}</strong>`;
        }

        function handleKeyPress(e) {
            if (e.key === ' ' || e.key === 'Spacebar') {
                e.preventDefault();
                
                const markerRect = marker.getBoundingClientRect();
                const successRect = successZone.getBoundingClientRect();
                const isSuccess = markerRect.left >= successRect.left && markerRect.right <= successRect.right;

                if (isSuccess) {
                    currentHits++;
                    updateCounter();
                    if (currentHits >= config.requiredHits) {
                        endGame(true);
                    } else {
                        randomizeSuccessZone();
                    }
                } else {
                    endGame(false);
                }
            }
        }

        function endGame(success) {
            clearTimeout(gameTimeout);
            document.removeEventListener('keydown', handleKeyPress);
            container.style.display = 'none';
            fetch(`https://catalyst_theft/minigameResult`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ success: success })
            });
        }

        // Start gry
        currentHits = 0;
        updateCounter();
        randomizeSuccessZone();
        container.style.display = 'block';
        document.addEventListener('keydown', handleKeyPress);
        gameTimeout = setTimeout(() => endGame(false), config.duration);
    }
});