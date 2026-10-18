document.addEventListener('DOMContentLoaded', () => {
    const menuButton = document.querySelector('.menu-toggle');
    const navigation = document.querySelector('.main-nav');

    if (menuButton && navigation) {
        menuButton.addEventListener('click', () => {
            const open = navigation.classList.toggle('is-open');
            menuButton.setAttribute('aria-expanded', String(open));
            menuButton.textContent = open ? 'Close' : 'Menu';
        });
    }

    document.querySelectorAll('form[data-confirm]').forEach((form) => {
        form.addEventListener('submit', (event) => {
            if (!window.confirm(form.dataset.confirm)) {
                event.preventDefault();
            }
        });
    });
});
