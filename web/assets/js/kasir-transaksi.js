(function () {
  const searchInput = document.getElementById('productSearch');
  const productItems = Array.from(document.querySelectorAll('.product-item'));
  const categoryButtons = Array.from(document.querySelectorAll('.category-filter'));
  const productListPanel = document.getElementById('productListPanel');
  const cartTableBody = document.getElementById('cartTableBody');
  const cartEmptyRow = document.getElementById('cartEmptyRow');
  const cartItemCountTop = document.getElementById('cartItemCountTop');
  const detailTotalItem = document.getElementById('detailTotalItem');
  const detailSubtotal = document.getElementById('detailSubtotal');
  const detailPpn = document.getElementById('detailPpn');
  const detailPaymentMethod = document.getElementById('detailPaymentMethod');
  const grandTotalText = document.getElementById('grandTotalText');
  const confirmTransactionBtn = document.getElementById('confirmTransactionBtn');
  const paymentButtons = Array.from(document.querySelectorAll('.payment-btn'));
  const checkoutForm = document.getElementById('checkoutForm');
  const checkoutPaymentMethod = document.getElementById('checkoutPaymentMethod');
  const checkoutInputs = document.getElementById('checkoutInputs');
  const profileModal = document.getElementById('profileModal');
  const confirmTransactionModal = document.getElementById('confirmTransactionModal');
  const confirmTransactionSummary = document.getElementById('confirmTransactionSummary');
  const confirmTransactionPayment = document.getElementById('confirmTransactionPayment');
  const confirmTransactionSubtotal = document.getElementById('confirmTransactionSubtotal');
  const confirmTransactionPpn = document.getElementById('confirmTransactionPpn');
  const confirmTransactionTotal = document.getElementById('confirmTransactionTotal');
  const confirmTransactionOk = document.getElementById('confirmTransactionOk');
  const confirmTransactionCancel = document.getElementById('confirmTransactionCancel');
  const confirmTransactionClose = document.getElementById('confirmTransactionClose');

  const cart = new Map();
  let activeCategory = 'all';
  let activePayment = 'tunai';
  const PPN_RATE = 0.11;

  function formatCurrency(value) {
    return 'Rp ' + Number(value || 0).toLocaleString('id-ID');
  }

  function renderCategoryState() {
    categoryButtons.forEach((button) => {
      const active = button.dataset.category === activeCategory;
      button.className = active
        ? 'category-filter rounded-full bg-[#0044ff] px-3 py-1.5 text-xs font-semibold text-white'
        : 'category-filter rounded-full bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-600 hover:bg-slate-200 transition-colors';
    });
  }

  function updateSummary(totalItem, subtotal, ppnAmount) {
    if (!cartItemCountTop || !detailTotalItem || !detailSubtotal || !detailPpn || !grandTotalText) {
      return;
    }
    cartItemCountTop.textContent = String(totalItem);
    detailTotalItem.textContent = String(totalItem);
    detailSubtotal.textContent = formatCurrency(subtotal);
    detailPpn.textContent = formatCurrency(ppnAmount);
    if (detailPaymentMethod) {
      detailPaymentMethod.textContent = activePayment === 'qris' ? 'QRIS' : 'TUNAI';
    }
    grandTotalText.textContent = formatCurrency(subtotal + ppnAmount);
  }

  function renderCart() {
    if (!cartTableBody || !cartEmptyRow) {
      return;
    }
    cartTableBody.querySelectorAll('.cart-row').forEach((row) => row.remove());
    cartEmptyRow.style.display = cart.size === 0 ? '' : 'none';

    let totalItem = 0;
    let subtotal = 0;
    let html = '';

    cart.forEach((item, code) => {
      totalItem += item.qty;
      subtotal += item.qty * item.price;
      html += `
        <tr class="cart-row border-b border-slate-100">
          <td class="px-5 py-4 text-center">
            <div class="flex flex-col items-center">
              <span class="text-sm font-semibold text-slate-900">${item.name}</span>
              <span class="text-xs text-slate-400">${item.code}</span>
            </div>
          </td>
          <td class="px-5 py-4 text-sm text-slate-700 text-center">${formatCurrency(item.price)}</td>
          <td class="px-5 py-4 text-center">
            <div class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-2 py-1">
              <button type="button" class="qty-minus rounded-lg px-2 py-1 text-slate-600 hover:bg-white" data-code="${code}">-</button>
              <span class="min-w-6 text-center text-sm font-semibold text-slate-900">${item.qty}</span>
              <button type="button" class="qty-plus rounded-lg px-2 py-1 text-slate-600 hover:bg-white" data-code="${code}">+</button>
            </div>
          </td>
          <td class="px-5 py-4 text-sm font-semibold text-[#0044ff] text-center">${formatCurrency(item.qty * item.price)}</td>
          <td class="px-5 py-4 text-center">
            <button type="button" class="remove-item rounded-lg px-2 py-1 text-xs font-semibold text-rose-600 hover:bg-rose-50" data-code="${code}">Hapus</button>
          </td>
        </tr>`;
    });

    cartTableBody.insertAdjacentHTML('beforeend', html);
    updateSummary(totalItem, subtotal, Math.round(subtotal * PPN_RATE));
  }

  function addToCart(productItem) {
    const productId = Number(productItem.dataset.id || 0);
    const code = productItem.dataset.code;
    const name = productItem.dataset.label;
    const price = Number(productItem.dataset.price || 0);
    const stock = Number(productItem.dataset.stock || 0);
    const existing = cart.get(code);

    if (existing) {
      if (existing.qty >= stock) {
        alert('Stok barang ini sudah habis.');
        return;
      }
      existing.qty += 1;
    } else {
      cart.set(code, { productId, code, name, price, qty: 1, stock });
    }

    renderCart();
  }

  function filterProducts() {
    if (!searchInput) return;
    const query = searchInput.value.toLowerCase().trim();
    productItems.forEach((item) => {
      const matchesText = !query || item.dataset.name.includes(query) || item.dataset.code.includes(query) || item.dataset.category.includes(query);
      const matchesCategory = activeCategory === 'all' || item.dataset.category === activeCategory.toLowerCase();
      item.style.display = matchesText && matchesCategory ? '' : 'none';
    });
  }

  function setPaymentMethod(method) {
    activePayment = method;
    paymentButtons.forEach((button) => {
      const active = button.dataset.payment === activePayment;
      button.className = active
        ? 'payment-btn rounded-xl border border-[#0044ff] bg-[#0044ff] px-4 py-3 text-sm font-semibold text-white shadow-sm'
        : 'payment-btn rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 shadow-sm';
    });
    updateSummary(
      Number(detailTotalItem.textContent || 0),
      Number(detailSubtotal.textContent.replace(/[Rp.\s]/g, '').replace(/,/g, '') || 0),
      Number(detailPpn.textContent.replace(/[Rp.\s]/g, '').replace(/,/g, '') || 0)
    );
  }

  function buildCheckoutInputs() {
    if (!checkoutInputs || !checkoutPaymentMethod) return;
    checkoutInputs.innerHTML = '';
    cart.forEach((item) => {
      const productIdInput = document.createElement('input');
      productIdInput.type = 'hidden';
      productIdInput.name = 'productId';
      productIdInput.value = String(item.productId);

      const qtyInput = document.createElement('input');
      qtyInput.type = 'hidden';
      qtyInput.name = 'qty';
      qtyInput.value = String(item.qty);

      checkoutInputs.appendChild(productIdInput);
      checkoutInputs.appendChild(qtyInput);
    });
    checkoutPaymentMethod.value = activePayment;
  }

  function updateRowQty(code, delta) {
    if (!cart.has(code)) return;
    const item = cart.get(code);
    if (!item) return;
    const nextQty = item.qty + delta;
    if (nextQty <= 0) {
      cart.delete(code);
    } else if (nextQty > item.stock) {
      alert('Stok barang ini tidak cukup.');
      return;
    } else {
      item.qty = nextQty;
    }
    renderCart();
  }

  function confirmTransaction() {
    if (!checkoutForm) return;
    if (cart.size === 0) {
      alert('Keranjang masih kosong.');
      return;
    }

    renderConfirmModal();
    setConfirmModalVisible(true);
  }

  function submitTransaction() {
    buildCheckoutInputs();
    setConfirmModalVisible(false);
    checkoutForm.submit();
  }

  function toggleModal(modalElement, visible) {
    if (!modalElement) return;
    modalElement.classList.toggle('hidden', !visible);
    modalElement.classList.toggle('flex', visible);
  }

  function setModalVisible(visible) {
    toggleModal(profileModal, visible);
  }

  function setConfirmModalVisible(visible) {
    toggleModal(confirmTransactionModal, visible);
  }

  function parseCurrency(text) {
    return Number(String(text || '0').replace(/[Rp.\s]/g, '').replace(/,/g, '') || 0) || 0;
  }

  function renderConfirmModal() {
    if (!confirmTransactionModal || !confirmTransactionSummary) return;

    const paymentText = activePayment === 'qris' ? 'QRIS' : 'TUNAI';
    const subtotal = parseCurrency(detailSubtotal ? detailSubtotal.textContent : '0');
    const ppn = parseCurrency(detailPpn ? detailPpn.textContent : '0');
    const total = subtotal + ppn;

    if (confirmTransactionPayment) {
      confirmTransactionPayment.textContent = 'Metode pembayaran: ' + paymentText;
    }

    confirmTransactionSummary.innerHTML = Array.from(cart.values()).map((item) => `
      <div class="flex items-center justify-between gap-4 rounded-xl bg-slate-50 px-4 py-3">
        <div>
          <p class="text-sm font-semibold text-slate-900">${item.name}</p>
          <p class="text-xs text-slate-500">${item.code}</p>
        </div>
        <span class="rounded-full bg-[#0044ff]/10 px-3 py-1 text-xs font-semibold text-[#0044ff]">x${item.qty}</span>
      </div>
    `).join('');

    if (confirmTransactionSubtotal) confirmTransactionSubtotal.textContent = formatCurrency(subtotal);
    if (confirmTransactionPpn) confirmTransactionPpn.textContent = formatCurrency(ppn);
    if (confirmTransactionTotal) confirmTransactionTotal.textContent = formatCurrency(total);
  }

  window.openProfileModal = function () {
    setModalVisible(true);
  };

  window.closeProfileModal = function () {
    setModalVisible(false);
  };

  if (searchInput) searchInput.addEventListener('input', filterProducts);
  categoryButtons.forEach((button) => button.addEventListener('click', () => {
    activeCategory = button.dataset.category;
    renderCategoryState();
    filterProducts();
  }));

  if (productListPanel) {
    productListPanel.addEventListener('click', (event) => {
      const card = event.target.closest('.product-item');
      if (card) addToCart(card);
    });
  }

  if (cartTableBody) {
    cartTableBody.addEventListener('click', (event) => {
      if (event.target.classList.contains('qty-minus')) updateRowQty(event.target.dataset.code, -1);
      if (event.target.classList.contains('qty-plus')) updateRowQty(event.target.dataset.code, 1);
      if (event.target.classList.contains('remove-item')) {
        cart.delete(event.target.dataset.code);
        renderCart();
      }
    });
  }

  paymentButtons.forEach((button) => button.addEventListener('click', () => setPaymentMethod(button.dataset.payment)));
  if (confirmTransactionBtn) confirmTransactionBtn.addEventListener('click', confirmTransaction);
  if (confirmTransactionOk) confirmTransactionOk.addEventListener('click', submitTransaction);
  if (confirmTransactionCancel) confirmTransactionCancel.addEventListener('click', () => setConfirmModalVisible(false));
  if (confirmTransactionClose) confirmTransactionClose.addEventListener('click', () => setConfirmModalVisible(false));
  if (confirmTransactionModal) {
    confirmTransactionModal.addEventListener('click', (event) => {
      if (event.target === confirmTransactionModal) {
        setConfirmModalVisible(false);
      }
    });
  }
  profileModal.addEventListener('click', (event) => {
    if (event.target === profileModal) setModalVisible(false);
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') setModalVisible(false);
  });

  if (categoryButtons.length) renderCategoryState();
  if (paymentButtons.length) setPaymentMethod(activePayment);
  if (cartTableBody && cartEmptyRow) renderCart();
})();