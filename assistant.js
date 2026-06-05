(function () {
  'use strict';

  // ─── CSS ────────────────────────────────────────────────────────────────────
  const CSS = `
    #ai-fab {
      position: fixed;
      bottom: 28px;
      right: 28px;
      z-index: 9998;
      width: 52px;
      height: 52px;
      border-radius: 50%;
      background: linear-gradient(135deg, #1a446c 0%, #2980b9 100%);
      border: none;
      cursor: pointer;
      box-shadow: 0 4px 16px rgba(26,68,108,0.35);
      display: flex;
      align-items: center;
      justify-content: center;
      transition: transform .2s, box-shadow .2s;
      color: #fff;
      font-size: 22px;
    }
    #ai-fab:hover { transform: scale(1.1); box-shadow: 0 6px 24px rgba(26,68,108,0.45); }

    #ai-popup-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,.35);
      z-index: 9999;
      display: none;
      align-items: flex-end;
      justify-content: flex-end;
      padding: 90px 28px 28px;
      backdrop-filter: blur(2px);
    }
    #ai-popup-overlay.open { display: flex; }

    #ai-popup {
      background: #fff;
      border-radius: 16px;
      box-shadow: 0 12px 48px rgba(0,0,0,.22);
      width: 440px;
      max-width: calc(100vw - 48px);
      max-height: 80vh;
      display: flex;
      flex-direction: column;
      font-family: 'Segoe UI', sans-serif;
      overflow: hidden;
      animation: aiPopIn .25s cubic-bezier(.34,1.56,.64,1);
    }
    @keyframes aiPopIn {
      from { opacity: 0; transform: scale(.92) translateY(12px); }
      to   { opacity: 1; transform: scale(1)  translateY(0); }
    }

    #ai-popup-header {
      background: linear-gradient(135deg, #1a446c 0%, #2176ae 100%);
      color: #fff;
      padding: 14px 18px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    #ai-popup-header h3 {
      margin: 0;
      font-size: 15px;
      font-weight: 600;
      flex: 1;
    }
    #ai-close-btn {
      background: none;
      border: none;
      color: #fff;
      font-size: 20px;
      cursor: pointer;
      line-height: 1;
      opacity: .75;
      padding: 0;
    }
    #ai-close-btn:hover { opacity: 1; }

    #ai-popup-tabs {
      display: flex;
      border-bottom: 2px solid #e8ecf0;
      background: #f8fafc;
    }
    .ai-tab {
      flex: 1;
      padding: 10px 6px;
      font-size: 13px;
      font-weight: 500;
      text-align: center;
      cursor: pointer;
      color: #6c757d;
      border: none;
      background: none;
      border-bottom: 2px solid transparent;
      margin-bottom: -2px;
      transition: color .15s, border-color .15s;
    }
    .ai-tab.active { color: #1a446c; border-bottom-color: #1a446c; font-weight: 700; }
    .ai-tab:hover:not(.active) { color: #2980b9; }

    #ai-popup-body {
      padding: 16px;
      flex: 1;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .ai-label {
      font-size: 12px;
      font-weight: 600;
      color: #495057;
      text-transform: uppercase;
      letter-spacing: .04em;
      margin-bottom: 4px;
    }

    #ai-input {
      width: 100%;
      min-height: 90px;
      padding: 10px 12px;
      border: 1.5px solid #dee2e6;
      border-radius: 8px;
      font-size: 14px;
      resize: vertical;
      font-family: inherit;
      box-sizing: border-box;
      transition: border-color .15s;
      line-height: 1.5;
    }
    #ai-input:focus { outline: none; border-color: #2980b9; }

    .ai-option-row {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }

    /* translate options */
    .ai-lang-btn {
      padding: 5px 12px;
      border-radius: 20px;
      border: 1.5px solid #dee2e6;
      background: #fff;
      font-size: 12px;
      cursor: pointer;
      transition: all .15s;
      color: #495057;
    }
    .ai-lang-btn.selected, .ai-lang-btn:hover {
      background: #1a446c;
      color: #fff;
      border-color: #1a446c;
    }

    #ai-run-btn {
      padding: 9px 18px;
      background: linear-gradient(135deg, #1a446c, #2980b9);
      color: #fff;
      border: none;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: opacity .15s, transform .1s;
      align-self: flex-start;
    }
    #ai-run-btn:hover { opacity: .9; }
    #ai-run-btn:active { transform: scale(.97); }
    #ai-run-btn:disabled { opacity: .55; cursor: not-allowed; }

    #ai-result-box {
      border: 1.5px solid #e8ecf0;
      border-radius: 8px;
      background: #f8fafc;
      padding: 12px;
      font-size: 14px;
      line-height: 1.65;
      white-space: pre-wrap;
      min-height: 60px;
      color: #212529;
      display: none;
      position: relative;
    }
    #ai-result-box.visible { display: block; }
    #ai-result-box.loading {
      display: block;
      color: #6c757d;
      font-style: italic;
    }

    #ai-copy-btn {
      position: absolute;
      top: 8px;
      right: 8px;
      padding: 3px 9px;
      font-size: 11px;
      border-radius: 5px;
      border: 1px solid #ced4da;
      background: #fff;
      cursor: pointer;
      color: #495057;
    }
    #ai-copy-btn:hover { background: #e9ecef; }

    .ai-error { color: #c0392b; font-style: normal !important; }

    /* highlight toggle */
    .ai-highlight-btn {
      font-size: 12px;
      padding: 4px 10px;
      border-radius: 6px;
      border: 1.5px solid #dee2e6;
      background: #fff;
      cursor: pointer;
      color: #495057;
    }
    .ai-highlight-btn.on { background: #fff3cd; border-color: #f0ad4e; color: #856404; }

    /* diff highlight */
    .ai-diff-del { background: #ffe0e0; text-decoration: line-through; border-radius: 2px; }
    .ai-diff-ins { background: #d4edda; border-radius: 2px; }
  `;

  // ─── HTML ────────────────────────────────────────────────────────────────────
  const HTML = `
    <button id="ai-fab" title="Trợ lý AI">✦</button>

    <div id="ai-popup-overlay">
      <div id="ai-popup">
        <div id="ai-popup-header">
          <span style="font-size:18px;">✦</span>
          <h3>Trợ lý AI — Chỉnh sửa & Dịch thuật</h3>
          <button id="ai-close-btn">✕</button>
        </div>

        <div id="ai-popup-tabs">
          <button class="ai-tab active" data-tab="spell"> Kiểm tra chính tả</button>
          <button class="ai-tab" data-tab="translate"> Dịch thuật</button>
          <button class="ai-tab" data-tab="rewrite"> Cải thiện văn phong</button>
        </div>

        <div id="ai-popup-body">
          <div>
            <div class="ai-label">Văn bản đầu vào</div>
            <textarea id="ai-input" placeholder="Dán hoặc nhập văn bản vào đây…"></textarea>
          </div>

          <div id="ai-translate-opts" style="display:none;">
            <div class="ai-label">Dịch sang</div>
            <div class="ai-option-row">
              <button class="ai-lang-btn selected" data-lang="Tiếng Anh">🇺🇸 Anh</button>
              <button class="ai-lang-btn" data-lang="Tiếng Việt">🇻🇳 Việt</button>
              <button class="ai-lang-btn" data-lang="Tiếng Trung">🇨🇳 Trung</button>
              <button class="ai-lang-btn" data-lang="Tiếng Nhật">🇯🇵 Nhật</button>
              <button class="ai-lang-btn" data-lang="Tiếng Pháp">🇫🇷 Pháp</button>
              <button class="ai-lang-btn" data-lang="Tiếng Hàn">🇰🇷 Hàn</button>
            </div>
          </div>

          <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
            <button id="ai-run-btn">Chạy</button>
            <button class="ai-highlight-btn" id="ai-diff-toggle" style="display:none;">Hiển thị thay đổi</button>
          </div>

          <div>
            <div class="ai-label" id="ai-result-label" style="display:none;">Kết quả</div>
            <div id="ai-result-box"></div>
          </div>
        </div>
      </div>
    </div>
  `;

  // ─── Init ────────────────────────────────────────────────────────────────────
  function init() {
    // Inject CSS
    const style = document.createElement('style');
    style.textContent = CSS;
    document.head.appendChild(style);

    // Inject HTML
    const wrapper = document.createElement('div');
    wrapper.innerHTML = HTML;
    document.body.appendChild(wrapper);

    // ── DOM refs ──
    const fab        = document.getElementById('ai-fab');
    const overlay    = document.getElementById('ai-popup-overlay');
    const closeBtn   = document.getElementById('ai-close-btn');
    const tabs       = document.querySelectorAll('.ai-tab');
    const input      = document.getElementById('ai-input');
    const runBtn     = document.getElementById('ai-run-btn');
    const resultBox  = document.getElementById('ai-result-box');
    const resultLbl  = document.getElementById('ai-result-label');
    const transOpts  = document.getElementById('ai-translate-opts');
    const langBtns   = document.querySelectorAll('.ai-lang-btn');
    const diffToggle = document.getElementById('ai-diff-toggle');
    const copyBtn    = document.createElement('button');
    copyBtn.id = 'ai-copy-btn';
    copyBtn.textContent = 'Sao chép';
    resultBox.appendChild(copyBtn);

    let currentTab  = 'spell';
    let selectedLang = 'Tiếng Anh';
    let lastRawResult = '';
    let diffOn = false;
    let lastInput = '';

    // ── Tabs ──
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        currentTab = tab.dataset.tab;
        transOpts.style.display = currentTab === 'translate' ? 'block' : 'none';
        clearResult();
      });
    });

    // ── Lang buttons ──
    langBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        langBtns.forEach(b => b.classList.remove('selected'));
        btn.classList.add('selected');
        selectedLang = btn.dataset.lang;
      });
    });

    // ── Open / Close ──
    fab.addEventListener('click', () => overlay.classList.add('open'));
    closeBtn.addEventListener('click', () => overlay.classList.remove('open'));
    overlay.addEventListener('click', e => { if (e.target === overlay) overlay.classList.remove('open'); });

    // ── Diff toggle ──
    diffToggle.addEventListener('click', () => {
      diffOn = !diffOn;
      diffToggle.classList.toggle('on', diffOn);
      diffToggle.textContent = diffOn ? 'Ẩn thay đổi' : 'Hiển thị thay đổi';
      if (lastRawResult) renderResult(lastRawResult);
    });

    // ── Copy ──
    copyBtn.addEventListener('click', () => {
      navigator.clipboard.writeText(lastRawResult).then(() => {
        copyBtn.textContent = 'Đã sao chép!';
        setTimeout(() => copyBtn.textContent = 'Sao chép', 1500);
      });
    });

    // ── Run ──
    runBtn.addEventListener('click', async () => {
      const text = input.value.trim();
      if (!text) { showError('Vui lòng nhập văn bản.'); return; }

      lastInput = text;
      runBtn.disabled = true;
      showLoading();

      const prompt = buildPrompt(currentTab, text, selectedLang);

      try {
        // https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}
        const response = await fetch('https://api.anthropic.com/v1/messages', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 1000,
            messages: [{ role: 'user', content: prompt }]
          })
        });

        const data = await response.json();
        if (data.error) throw new Error(data.error.message);
        const result = data.content?.find(b => b.type === 'text')?.text || '';
        lastRawResult = result.trim();
        renderResult(lastRawResult);

        if (currentTab === 'spell') {
          diffToggle.style.display = 'inline-block';
        } else {
          diffToggle.style.display = 'none';
          diffOn = false;
        }
      } catch (err) {
        showError('Lỗi kết nối API: ' + err.message);
      } finally {
        runBtn.disabled = false;
      }
    });

    // ── Helpers ──
    function buildPrompt(tab, text, lang) {
      if (tab === 'spell') {
        return `Bạn là trợ lý chỉnh sửa văn bản tiếng Việt. Hãy kiểm tra và sửa lỗi chính tả, ngữ pháp, dấu câu trong đoạn văn sau. Chỉ trả về văn bản đã sửa, không giải thích.\n\n${text}`;
      }
      if (tab === 'translate') {z
        return `Dịch đoạn văn sau sang ${lang}. Chỉ trả về bản dịch, không giải thích.\n\n${text}`;
      }
      if (tab === 'rewrite') {
        return `Cải thiện văn phong đoạn văn sau: làm cho nó chuyên nghiệp, rõ ràng, mạch lạc hơn. Chỉ trả về văn bản đã cải thiện, không giải thích.\n\n${text}`;
      }
    }

    function showLoading() {
      resultBox.className = 'loading';
      resultBox.innerHTML = 'Đang xử lý…';
      resultBox.appendChild(copyBtn);
      resultLbl.style.display = 'block';
      copyBtn.style.display = 'none';
    }

    function renderResult(text) {
      resultBox.className = 'visible';
      resultLbl.style.display = 'block';
      copyBtn.style.display = 'block';

      if (diffOn && currentTab === 'spell') {
        resultBox.innerHTML = '';
        resultBox.appendChild(copyBtn);
        const diffEl = document.createElement('div');
        diffEl.innerHTML = computeDiff(lastInput, text);
        resultBox.insertBefore(diffEl, copyBtn);
      } else {
        resultBox.innerHTML = '';
        resultBox.appendChild(copyBtn);
        const pre = document.createElement('span');
        pre.textContent = text;
        resultBox.insertBefore(pre, copyBtn);
      }
    }

    function showError(msg) {
      resultBox.className = 'visible';
      resultLbl.style.display = 'block';
      resultBox.innerHTML = `<span class="ai-error">⚠ ${msg}</span>`;
      resultBox.appendChild(copyBtn);
      copyBtn.style.display = 'none';
    }

    function clearResult() {
      resultBox.className = '';
      resultBox.innerHTML = '';
      resultBox.appendChild(copyBtn);
      resultLbl.style.display = 'none';
      diffToggle.style.display = 'none';
      lastRawResult = '';
    }

    // Simple word-level diff
    function computeDiff(original, revised) {
      const orig = original.split(/(\s+)/);
      const rev  = revised.split(/(\s+)/);
      const dp   = Array.from({ length: orig.length + 1 }, () => new Array(rev.length + 1).fill(0));
      for (let i = orig.length - 1; i >= 0; i--)
        for (let j = rev.length - 1; j >= 0; j--)
          dp[i][j] = orig[i] === rev[j]
            ? dp[i+1][j+1] + 1
            : Math.max(dp[i+1][j], dp[i][j+1]);

      let i = 0, j = 0, out = '';
      while (i < orig.length || j < rev.length) {
        if (i < orig.length && j < rev.length && orig[i] === rev[j]) {
          out += escHtml(orig[i]); i++; j++;
        } else if (j < rev.length && (i >= orig.length || dp[i][j+1] >= dp[i+1][j])) {
          out += `<span class="ai-diff-ins">${escHtml(rev[j])}</span>`; j++;
        } else {
          out += `<span class="ai-diff-del">${escHtml(orig[i])}</span>`; i++;
        }
      }
      return out;
    }

    function escHtml(s) {
      return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();