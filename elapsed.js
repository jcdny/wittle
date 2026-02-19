function startElapsedTimer(pastDate, elementId) {
  const el = document.getElementById(elementId);

  function update() {
    const now = new Date();
    const diffMs = now - new Date(pastDate);

    if (diffMs < 0) {
      el.textContent = "Date is in the future";
      return;
    }

    const seconds = Math.floor(diffMs / 1000) % 60;
    const minutes = Math.floor(diffMs / (1000 * 60)) % 60;
    const hours = Math.floor(diffMs / (1000 * 60 * 60)) % 24;
    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    el.textContent =
      `${days}d ${hours}h ${minutes}m ${seconds}s`;
  }

  update(); // initial call
  return setInterval(update, 1000);
}

// Example usage: startElapsedTimer("2025-01-01T00:00:00", "elapsed");
