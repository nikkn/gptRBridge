build_ui <- function() {
  miniUI::miniPage(
    shiny::tags$head(
      shiny::tags$link(
        rel = "stylesheet",
        href = "https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css"
      ),
      shiny::tags$script(
        defer = NA,
        src = "https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"
      ),
      shiny::tags$script(
        defer = NA,
        src = "https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"
      ),
      shiny::tags$style(shiny::HTML(ui_css())),
      shiny::tags$script(shiny::HTML(ui_js()))
    ),

    shiny::div(
      class = "header-bar",
      shiny::div(class = "header-title", "gpt-R-Bridge"),
      shiny::div(
        class = "header-actions",
        shiny::conditionalPanel(
          condition = "output.is_logged_in",
          shiny::actionButton("btn_logout", "Logout", class = "btn-header")
        ),
        shiny::actionButton("done", "Close", class = "btn-header")
      )
    ),

    shiny::div(
      class = "main-content",

      shiny::conditionalPanel(
        condition = "!output.is_logged_in",
        shiny::div(
          class = "login-card",
          shiny::div(class = "login-icon", "R"),
          shiny::h4("Sign in to gpt-R-Bridge"),
          shiny::textInput("email", NULL, placeholder = "Email"),
          shiny::passwordInput("password", NULL, placeholder = "Password"),
          shiny::div(
            class = "btn-row",
            shiny::actionButton("btn_login", "Log in",
                                class = "btn-primary btn-login"),
            shiny::actionButton("btn_register", "Register",
                                class = "btn-default btn-register")
          ),
          shiny::p(
            class = "register-hook",
            "Register now and get your 50 free trial calls."
          ),
          shiny::uiOutput("login_status")
        )
      ),

      shiny::conditionalPanel(
        condition = "output.is_logged_in",
        shiny::div(
          class = "chat-container",
          shiny::div(
            class = "chat-history",
            id = "chat_history_panel",
            shiny::uiOutput("chat_messages")
          ),
          shiny::div(class = "splitter", id = "splitter"),
          shiny::div(
            class = "chat-input-area",
            id = "chat_input_panel",
            shiny::textAreaInput(
              "user_msg", label = NULL,
              placeholder = "Ask something about your data\u2026\nCaptured console output will appear here automatically.",
              rows = 6
            ),
            shiny::div(
              class = "btn-row",
              shiny::actionButton("btn_send", "Send",
                                  class = "btn-primary btn-send"),
              shiny::tags$label(
                class = "auto-insert-label",
                shiny::tags$input(type = "checkbox", id = "chk_auto_insert",
                                  checked = "checked"),
                "Insert output automatically"
              )
            )
          )
        )
      )
    )
  )
}


ui_js <- function() {
  "
  Shiny.addCustomMessageHandler('do_chat', function(data) {
    fetch(data.base_url + '/ai/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + data.token
      },
      body: JSON.stringify({messages: data.messages})
    })
    .then(function(response) {
      var status = response.status;
      return response.json().then(function(body) { return {status: status, body: body}; });
    })
    .then(function(r) {
      if (r.status === 200) {
        Shiny.setInputValue('chat_response', {
          ok: true,
          reply: r.body.reply,
          tokens_used: r.body.tokens_used,
          ts: Date.now()
        }, {priority: 'event'});
      } else {
        Shiny.setInputValue('chat_response', {
          ok: false,
          status: r.status,
          detail: r.body.detail || 'Request failed (HTTP ' + r.status + ')',
          ts: Date.now()
        }, {priority: 'event'});
      }
    })
    .catch(function(err) {
      Shiny.setInputValue('chat_response', {
        ok: false,
        status: 0,
        detail: err.message || 'Network error',
        ts: Date.now()
      }, {priority: 'event'});
    });
  });

  $(document).on('click', '#btn_register', function() {
    $('#login_status').html(
      '<div style=\"color:#888;font-style:italic;margin-top:10px\">' +
      'Creating account' +
      '<span class=\"thinking-dots\" style=\"margin-left:6px\">' +
      '<span></span><span></span><span></span></span></div>'
    );
  });

  $(document).on('click', '.code-insert-btn', function(e) {
    e.stopPropagation();
    var code = $(this).closest('.code-block-wrap').find('pre code').text();
    Shiny.setInputValue('insert_code_click', code, {priority: 'event'});
  });

  $(document).on('shiny:value', function(e) {
    if (e.name === 'chat_messages') {
      setTimeout(function() {
        var el = document.querySelector('.chat-history');
        if (el) {
          if (typeof renderMathInElement === 'function') {
            renderMathInElement(el, {
              delimiters: [
                {left: '$$', right: '$$', display: true},
                {left: '\\\\[', right: '\\\\]', display: true},
                {left: '\\\\(', right: '\\\\)', display: false},
                {left: '$', right: '$', display: false}
              ],
              throwOnError: false
            });
          }
          el.scrollTop = el.scrollHeight;
        }
      }, 50);
    }
  });

  $(document).on('change', '#chk_auto_insert', function() {
    Shiny.setInputValue('chk_auto_insert', this.checked);
  });

  $(document).on('shiny:connected', function() {
    var cb = document.getElementById('chk_auto_insert');
    if (cb) Shiny.setInputValue('chk_auto_insert', cb.checked);
  });

  $(document).ready(function() {
    var splitter = document.getElementById('splitter');
    if (!splitter) return;
    var isDragging = false;
    var container, topPanel, bottomPanel;

    splitter.addEventListener('mousedown', function(e) {
      e.preventDefault();
      isDragging = true;
      container = splitter.parentElement;
      topPanel = document.getElementById('chat_history_panel');
      bottomPanel = document.getElementById('chat_input_panel');
      document.body.style.cursor = 'row-resize';
      document.body.style.userSelect = 'none';
    });

    document.addEventListener('mousemove', function(e) {
      if (!isDragging) return;
      var containerRect = container.getBoundingClientRect();
      var containerH = containerRect.height;
      var offsetY = e.clientY - containerRect.top;
      var pct = (offsetY / containerH) * 100;
      pct = Math.max(15, Math.min(85, pct));
      topPanel.style.flex = '0 0 ' + pct + '%';
      bottomPanel.style.flex = '0 0 ' + (100 - pct - 1) + '%';
    });

    document.addEventListener('mouseup', function() {
      if (isDragging) {
        isDragging = false;
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
      }
    });
  });
  "
}


ui_css <- function() {
  "
  body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
  .gadget-title { display: none !important; }

  .header-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 16px;
    background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
    color: #fff;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    position: relative;
    z-index: 10;
    flex-shrink: 0;
  }
  .header-title {
    font-size: 17px;
    font-weight: 700;
    letter-spacing: 0.5px;
    color: #ecf0f1;
  }
  .header-actions {
    display: flex;
    gap: 6px;
    align-items: center;
  }
  .btn-header {
    background: rgba(255,255,255,0.15);
    border: 1px solid rgba(255,255,255,0.3);
    color: #fff;
    font-size: 11px;
    padding: 3px 10px;
    border-radius: 4px;
    cursor: pointer;
    transition: background 0.2s;
  }
  .btn-header:hover {
    background: rgba(255,255,255,0.25);
    color: #fff;
  }

  .main-content {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    padding-top: 46px;
    overflow: hidden;
  }

  .main-content > .shiny-bound-output,
  .main-content > div[data-display-if] {
    height: 100%;
  }

  .login-card {
    max-width: 320px;
    margin: 40px auto;
    padding: 28px 24px;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    text-align: center;
  }
  .login-icon {
    width: 48px;
    height: 48px;
    margin: 0 auto 12px;
    background: linear-gradient(135deg, #3498db, #2c3e50);
    color: #fff;
    font-size: 24px;
    font-weight: 800;
    line-height: 48px;
    border-radius: 12px;
  }
  .login-card h4 {
    margin: 0 0 18px;
    color: #2c3e50;
    font-size: 16px;
    font-weight: 600;
  }
  .login-card .form-group {
    margin-bottom: 12px;
    text-align: left;
  }
  .login-card .form-control {
    border-radius: 6px;
    border: 1px solid #dce1e8;
    padding: 8px 12px;
    font-size: 13px;
    transition: border-color 0.2s;
  }
  .login-card .form-control:focus {
    border-color: #3498db;
    box-shadow: 0 0 0 3px rgba(52,152,219,0.12);
  }
  .btn-login {
    width: 100%;
    padding: 9px;
    border-radius: 6px;
    font-weight: 600;
    font-size: 14px;
    background: #3498db;
    border-color: #2980b9;
  }
  .btn-login:hover {
    background: #2980b9;
  }
  .btn-register {
    width: 100%;
    padding: 8px;
    border-radius: 6px;
    font-size: 13px;
    margin-top: 6px;
  }
  #login_status {
    margin-top: 12px;
    font-size: 13px;
  }
  .register-hook {
    font-size: 11px;
    color: #7f8c8d;
    margin-top: 10px;
    margin-bottom: 0;
    text-align: center;
  }

  .chat-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding: 10px;
    box-sizing: border-box;
  }
  .chat-history {
    flex: 1 1 50%;
    overflow-y: auto;
    padding: 12px;
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    min-height: 0;
  }

  .splitter {
    flex: 0 0 6px;
    background: #e0e4e8;
    border-radius: 3px;
    margin: 4px 0;
    cursor: row-resize;
    transition: background 0.15s;
    position: relative;
  }
  .splitter:hover,
  .splitter:active {
    background: #3498db;
  }
  .splitter::after {
    content: '';
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    width: 30px;
    height: 2px;
    background: rgba(0,0,0,0.2);
    border-radius: 1px;
  }
  .splitter:hover::after {
    background: rgba(255,255,255,0.5);
  }

  .chat-input-area {
    flex: 1 1 50%;
    display: flex;
    flex-direction: column;
    min-height: 0;
  }
  .chat-input-area .shiny-input-container {
    width: 100% !important;
    max-width: 100% !important;
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    margin-bottom: 8px;
    min-height: 0;
  }
  .chat-input-area .form-group {
    width: 100% !important;
    max-width: 100% !important;
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    margin-bottom: 8px;
    min-height: 0;
  }
  .chat-input-area textarea {
    flex: 1 1 auto;
    width: 100% !important;
    max-width: 100% !important;
    resize: none !important;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    padding: 10px 12px;
    font-size: 13px;
    font-family: inherit;
    transition: border-color 0.2s;
    box-sizing: border-box;
  }
  .chat-input-area textarea:focus {
    border-color: #3498db;
    box-shadow: 0 0 0 3px rgba(52,152,219,0.1);
    outline: none;
  }

  .btn-row {
    display: flex;
    gap: 10px;
    align-items: center;
    flex-wrap: wrap;
    flex-shrink: 0;
  }
  .btn-send {
    padding: 8px 28px;
    border-radius: 6px;
    font-weight: 600;
    font-size: 14px;
    background: #3498db;
    border-color: #2980b9;
    color: #fff;
    transition: background 0.2s;
  }
  .btn-send:hover {
    background: #2980b9;
    color: #fff;
  }

  .auto-insert-label {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 12px;
    color: #6c757d;
    cursor: pointer;
    user-select: none;
  }
  .auto-insert-label input[type='checkbox'] {
    margin: 0;
    cursor: pointer;
  }

  .chat-bubble {
    margin-bottom: 10px;
    padding: 10px 14px;
    border-radius: 10px;
    max-width: 88%;
    word-wrap: break-word;
    white-space: pre-wrap;
    font-size: 13px;
    line-height: 1.5;
  }
  .chat-bubble.user {
    background: linear-gradient(135deg, #d6eaf8, #aed6f1);
    margin-left: auto;
    text-align: left;
    border-bottom-right-radius: 3px;
  }
  .chat-bubble.assistant {
    background: #fff;
    border: 1px solid #e9ecef;
    margin-right: auto;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    border-bottom-left-radius: 3px;
  }

  .code-block-wrap {
    position: relative;
    margin: 8px 0;
  }
  .code-block-wrap pre {
    background: #1e1e2e !important;
    color: #cdd6f4 !important;
    padding: 12px;
    padding-top: 32px;
    border-radius: 6px;
    overflow-x: auto;
    white-space: pre;
    font-size: 12px;
    font-family: 'Fira Code', 'Consolas', monospace;
    line-height: 1.5;
    margin: 0;
  }
  .code-block-wrap pre code {
    background: transparent !important;
    color: #cdd6f4 !important;
    padding: 0 !important;
    border-radius: 0 !important;
    font-size: inherit;
    font-family: inherit;
  }
  .code-insert-btn {
    position: absolute;
    top: 6px;
    right: 6px;
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.2);
    color: #cdd6f4;
    font-size: 11px;
    padding: 2px 10px;
    border-radius: 4px;
    cursor: pointer;
    transition: background 0.2s;
    z-index: 2;
  }
  .code-insert-btn:hover {
    background: rgba(255,255,255,0.25);
  }

  .chat-bubble > code {
    background: #e8ecf1;
    color: #2c3e50;
    padding: 1px 5px;
    border-radius: 3px;
    font-size: 12px;
    font-family: 'Fira Code', 'Consolas', monospace;
  }

  .thinking-bubble {
    min-width: 56px;
    padding: 12px 16px;
  }
  .thinking-dots {
    display: inline-flex;
    gap: 5px;
    align-items: center;
  }
  .thinking-dots span {
    width: 7px;
    height: 7px;
    background: #adb5bd;
    border-radius: 50%;
    animation: thinking-blink 1.3s ease-in-out infinite;
  }
  .thinking-dots span:nth-child(2) { animation-delay: 0.22s; }
  .thinking-dots span:nth-child(3) { animation-delay: 0.44s; }
  @keyframes thinking-blink {
    0%, 80%, 100% { opacity: 0.2; transform: scale(0.85); }
    40%           { opacity: 1;   transform: scale(1);    }
  }

  .trial-exhausted-banner {
    background: #fffbf0;
    border-left: 4px solid #f0a500;
    border-radius: 0 6px 6px 0;
    padding: 14px 16px;
    font-size: 13px;
    color: #3d3d3d;
    margin-bottom: 10px;
    line-height: 1.7;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
  .trial-exhausted-banner strong {
    font-size: 13px;
    color: #1a1a1a;
  }
  .btn-subscribe-inline {
    margin-top: 10px;
    background: #3498db;
    border-color: #2980b9;
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    border-radius: 5px;
    padding: 6px 18px;
  }
  .btn-subscribe-inline:hover {
    background: #2980b9;
    color: #fff;
  }
  "
}
