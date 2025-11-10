$(function() {
    let currentBalance = 0;

    // Gestion des messages depuis le client
    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.action) {
            case 'openBank':
                openBank(data.balance);
                break;
            case 'closeBank':
                closeBank();
                break;
            case 'updateBalance':
                updateBalance(data.balance);
                break;
        }
    });

    // Ouvrir la banque
    function openBank(balance) {
        currentBalance = balance || 0;
        updateBalance(currentBalance);
        $('#bank-container').fadeIn(300);
    }

    // Fermer la banque
    function closeBank() {
        $('#bank-container').fadeOut(300);
        resetInputs();
    }

    // Mettre à jour le solde
    function updateBalance(balance) {
        currentBalance = balance;
        $('#balance-amount').text('$' + formatNumber(balance));
    }

    // Formater les nombres avec des espaces
    function formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    }

    // Réinitialiser les inputs
    function resetInputs() {
        $('input[type="number"]').val('');
    }

    // Bouton de fermeture
    $('#close-btn').click(function() {
        $.post('https://banque/close', JSON.stringify({}));
    });

    // Gestion des onglets
    $('.tab-btn').click(function() {
        const tab = $(this).data('tab');

        $('.tab-btn').removeClass('active');
        $(this).addClass('active');

        $('.tab-pane').removeClass('active');
        $('#' + tab + '-tab').addClass('active');

        resetInputs();
    });

    // Boutons de montants rapides
    $('.quick-btn').click(function() {
        const action = $(this).data('action');
        const amount = $(this).data('amount');

        $('#' + action + '-amount').val(amount);
    });

    // Bouton Déposer
    $('#deposit-btn').click(function() {
        const amount = parseInt($('#deposit-amount').val());

        if (amount && amount > 0) {
            $.post('https://banque/deposit', JSON.stringify({
                amount: amount
            }));
            resetInputs();
        } else {
            // Notification d'erreur (optionnel)
            console.log('Montant invalide');
        }
    });

    // Bouton Retirer
    $('#withdraw-btn').click(function() {
        const amount = parseInt($('#withdraw-amount').val());

        if (amount && amount > 0) {
            if (amount <= currentBalance) {
                $.post('https://banque/withdraw', JSON.stringify({
                    amount: amount
                }));
                resetInputs();
            } else {
                // Notification d'erreur (optionnel)
                console.log('Solde insuffisant');
            }
        } else {
            // Notification d'erreur (optionnel)
            console.log('Montant invalide');
        }
    });

    // Bouton Transférer
    $('#transfer-btn').click(function() {
        const targetId = parseInt($('#transfer-id').val());
        const amount = parseInt($('#transfer-amount').val());

        if (targetId && amount && amount > 0) {
            if (amount <= currentBalance) {
                $.post('https://banque/transfer', JSON.stringify({
                    target: targetId,
                    amount: amount
                }));
                resetInputs();
            } else {
                // Notification d'erreur (optionnel)
                console.log('Solde insuffisant');
            }
        } else {
            // Notification d'erreur (optionnel)
            console.log('Données invalides');
        }
    });

    // Fermer avec la touche ESC
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            $.post('https://banque/close', JSON.stringify({}));
        }
    });

    // Permettre l'entrée avec Enter
    $('input').keypress(function(e) {
        if (e.which === 13) { // Touche Enter
            const currentTab = $('.tab-btn.active').data('tab');

            switch(currentTab) {
                case 'deposit':
                    $('#deposit-btn').click();
                    break;
                case 'withdraw':
                    $('#withdraw-btn').click();
                    break;
                case 'transfer':
                    $('#transfer-btn').click();
                    break;
            }
        }
    });
});
