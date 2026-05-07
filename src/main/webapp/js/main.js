// ============================================================
// EventHorizon - Main JavaScript
// ============================================================

document.addEventListener('DOMContentLoaded', function () {

    // -------- Mobile Navbar Toggle --------
    const hamburger = document.querySelector('.hamburger');
    const navLinks  = document.querySelector('.navbar-links');

    if (hamburger && navLinks) {
        hamburger.addEventListener('click', function () {
            navLinks.classList.toggle('open');
            hamburger.classList.toggle('active');
        });

        // Close on outside click
        document.addEventListener('click', function (e) {
            if (!hamburger.contains(e.target) && !navLinks.contains(e.target)) {
                navLinks.classList.remove('open');
                hamburger.classList.remove('active');
            }
        });
    }

    // -------- Auto-dismiss alerts --------
    const alerts = document.querySelectorAll('.alert[data-auto-dismiss]');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.opacity = '0';
            alert.style.transition = 'opacity 0.5s';
            setTimeout(function () { alert.remove(); }, 500);
        }, 3500);
    });

    // -------- Ticket price calculator --------
    const ticketInput = document.getElementById('numberOfTickets');
    const pricePerTicket = document.getElementById('pricePerTicket');
    const totalDisplay  = document.getElementById('totalAmount');

    if (ticketInput && pricePerTicket && totalDisplay) {
        ticketInput.addEventListener('input', function () {
            const qty   = parseInt(this.value) || 0;
            const price = parseFloat(pricePerTicket.value) || 0;
            const total = (qty * price).toFixed(2);
            totalDisplay.textContent = 'LKR ' + Number(total).toLocaleString();
        });
    }

    // -------- Delete confirmation modal --------
    const deleteButtons = document.querySelectorAll('[data-confirm-delete]');
    deleteButtons.forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            const message = this.dataset.confirmDelete || 'Are you sure you want to delete this?';
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });

    // -------- Modal open/close --------
    document.querySelectorAll('[data-modal-open]').forEach(function (trigger) {
        trigger.addEventListener('click', function () {
            const modalId = this.dataset.modalOpen;
            const overlay = document.getElementById(modalId);
            if (overlay) overlay.classList.add('active');
        });
    });

    document.querySelectorAll('[data-modal-close]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const modalId = this.dataset.modalClose;
            const overlay = document.getElementById(modalId);
            if (overlay) overlay.classList.remove('active');
        });
    });

    // Close modal on overlay click
    document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === this) this.classList.remove('active');
        });
    });

    // -------- Seats bar animation --------
    const bars = document.querySelectorAll('.seats-bar-fill[data-pct]');
    bars.forEach(function (bar) {
        const pct = parseFloat(bar.dataset.pct) || 0;
        bar.style.width = pct + '%';
        if (pct < 20) bar.style.background = '#ef4444';
        else if (pct < 50) bar.style.background = '#f59e0b';
    });

    // -------- Search filter (client-side quick filter) --------
    const searchInput = document.getElementById('liveSearch');
    if (searchInput) {
        searchInput.addEventListener('input', function () {
            const q = this.value.toLowerCase();
            document.querySelectorAll('[data-searchable]').forEach(function (item) {
                const text = item.dataset.searchable.toLowerCase();
                item.closest('[data-search-row]').style.display =
                    text.includes(q) ? '' : 'none';
            });
        });
    }

    // -------- Form validation --------
    const authForms = document.querySelectorAll('.needs-validation');
    authForms.forEach(function (form) {
        form.addEventListener('submit', function (e) {
            let valid = true;
            form.querySelectorAll('[required]').forEach(function (field) {
                if (!field.value.trim()) {
                    field.style.borderColor = '#ef4444';
                    valid = false;
                } else {
                    field.style.borderColor = '';
                }
            });

            // Password match check
            const pwd  = form.querySelector('#password');
            const pwd2 = form.querySelector('#confirmPassword');
            if (pwd && pwd2 && pwd.value !== pwd2.value) {
                pwd2.style.borderColor = '#ef4444';
                showInlineError(pwd2, 'Passwords do not match');
                valid = false;
            }

            if (!valid) e.preventDefault();
        });
    });

    function showInlineError(field, msg) {
        let err = field.parentNode.querySelector('.field-error');
        if (!err) {
            err = document.createElement('span');
            err.className = 'field-error';
            err.style.cssText = 'color:#fca5a5;font-size:0.8rem;margin-top:4px;display:block;';
            field.parentNode.appendChild(err);
        }
        err.textContent = msg;
    }

    // -------- Smooth scroll for anchor links --------
    document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
        anchor.addEventListener('click', function (e) {
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                e.preventDefault();
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });

    // -------- Category emoji map --------
    window.getCategoryEmoji = function (category) {
        const map = {
            'Concert':    '🎵',
            'Sports':     '⚽',
            'Technology': '💻',
            'Cultural':   '🎭',
            'Theater':    '🎬',
            'Comedy':     '😂',
            'Art':        '🎨',
            'Food':       '🍽️',
        };
        return map[category] || '🎟️';
    };

});
