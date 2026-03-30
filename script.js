function openModal() {
  const modal = document.getElementById("postModal");
  modal.style.display = "flex";
}

function closeModal() {
  const modal = document.getElementById("postModal");
  modal.style.display = "none";
}

function publishPost() {
  const input = document.getElementById("postInput");
  const text = input.value.trim();

  if (text === "") {
    alert("Écris quelque chose !");
    return;
  }

  const feed = document.querySelector(".feed");

  const newPost = document.createElement("article");
  newPost.className = "post-card";

  newPost.innerHTML = `
    <div class="post-top">
      <div class="user">
        <div class="avatar">Y</div>
        <div>
          <h3>Toi</h3>
          <p>Maintenant</p>
        </div>
      </div>
      <button class="dots">•••</button>
    </div>

    <p class="post-text">${text}</p>

    <div class="post-actions">
      <span>♡</span>
      <span>💬</span>
      <span>↗</span>
    </div>
  `;

  feed.prepend(newPost);
  input.value = "";
  closeModal();
}

// =========================================================
// Auth (front-only) - localStorage
// =========================================================

const YC_STORAGE_KEYS = {
  users: "yc_users_v1",
  session: "yc_session_v1",
  accessRequests: "yc_access_requests_v1",
};

const YC_CAMPUSES_FR = [
  "Aix Ynov Campus",
  "Bordeaux Ynov Campus",
  "Connect Ynov Campus",
  "Lille Ynov Campus",
  "Lyon Ynov Campus",
  "Montpellier Ynov Campus",
  "Nantes Ynov Campus",
  "Paris Ynov Campus",
  "Rennes Ynov Campus",
  "Rouen Ynov Campus",
  "Strasbourg Ynov Campus",
  "Sophia Ynov Campus",
  "Toulouse Ynov Campus",
  "Val d'Europe Ynov Campus",
  "Lyon EICAR Campus",
  "Paris EICAR Campus",
];

function ycNowIso() {
  return new Date().toISOString();
}

function ycNormalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function ycIsYnovEmail(email) {
  const e = ycNormalizeEmail(email);
  return e.endsWith("@ynov.com");
}

function ycLoadJson(key, fallback) {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function ycSaveJson(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

function ycGetUsers() {
  return ycLoadJson(YC_STORAGE_KEYS.users, []);
}

function ycSetUsers(users) {
  ycSaveJson(YC_STORAGE_KEYS.users, users);
}

function ycSetSession(session) {
  ycSaveJson(YC_STORAGE_KEYS.session, session);
}

function ycGetSession() {
  return ycLoadJson(YC_STORAGE_KEYS.session, null);
}

function ycClearSession() {
  localStorage.removeItem(YC_STORAGE_KEYS.session);
}

function ycGetAccessRequests() {
  return ycLoadJson(YC_STORAGE_KEYS.accessRequests, []);
}

function ycSetAccessRequests(reqs) {
  ycSaveJson(YC_STORAGE_KEYS.accessRequests, reqs);
}

function ycShowAlert(elId, message, variant) {
  const el = document.getElementById(elId);
  if (!el) return;
  el.style.display = "block";
  el.className = `auth-alert ${variant || "info"}`;
  el.textContent = message;
}

function ycMakeId(prefix) {
  return `${prefix}_${Math.random().toString(16).slice(2)}_${Date.now()}`;
}

function ycRegister(event) {
  event.preventDefault();

  const displayName = document.getElementById("regDisplayName")?.value?.trim();
  const username = document.getElementById("regUsername")?.value?.trim();
  const emailRaw = document.getElementById("regEmail")?.value;
  const campus = document.getElementById("regCampus")?.value?.trim() || "";
  const email = ycNormalizeEmail(emailRaw);
  const password = document.getElementById("regPassword")?.value || "";
  const reason = document.getElementById("regReason")?.value?.trim() || "";

  if (!displayName || !username || !email || !campus || !password) {
    ycShowAlert("registerAlert", "Merci de remplir tous les champs obligatoires.", "error");
    return;
  }

  if (password.length < 8) {
    ycShowAlert("registerAlert", "Le mot de passe doit faire au moins 8 caractères.", "error");
    return;
  }

  const users = ycGetUsers();
  const emailExists = users.some((u) => ycNormalizeEmail(u.email) === email);
  const usernameExists = users.some((u) => String(u.username).toLowerCase() === String(username).toLowerCase());

  if (emailExists) {
    ycShowAlert("registerAlert", "Cet email est déjà utilisé. Essaie de te connecter.", "error");
    return;
  }
  if (usernameExists) {
    ycShowAlert("registerAlert", "Ce username est déjà pris.", "error");
    return;
  }

  const isYnov = ycIsYnovEmail(email);
  const status = isYnov ? "active" : "pending_admin";

  // Démo front-only: on stocke le mot de passe (à ne pas faire en production).
  const newUser = {
    id: ycMakeId("user"),
    displayName,
    username,
    email,
    campus,
    password,
    status,
    createdAt: ycNowIso(),
  };

  users.push(newUser);
  ycSetUsers(users);

  if (isYnov) {
    ycSetSession({ userId: newUser.id, createdAt: ycNowIso() });
    ycShowAlert("registerAlert", "Compte créé. Connexion en cours...", "success");
    setTimeout(() => (window.location.href = "index.html"), 600);
    return;
  }

  const reqs = ycGetAccessRequests();
  reqs.push({
    id: ycMakeId("req"),
    email,
    displayName,
    username,
    campus,
    reason,
    status: "pending",
    createdAt: ycNowIso(),
  });
  ycSetAccessRequests(reqs);

  ycShowAlert(
    "registerAlert",
    "Email non @ynov.com : demande envoyée à l’admin. Ton compte est en attente.",
    "info"
  );
}

function ycLogin(event) {
  event.preventDefault();

  const emailRaw = document.getElementById("loginEmail")?.value;
  const email = ycNormalizeEmail(emailRaw);
  const campus = document.getElementById("loginCampus")?.value?.trim() || "";
  const password = document.getElementById("loginPassword")?.value || "";

  if (!email || !campus || !password) {
    ycShowAlert("loginAlert", "Merci de remplir email, campus et mot de passe.", "error");
    return;
  }

  const users = ycGetUsers();
  const user = users.find((u) => ycNormalizeEmail(u.email) === email);

  if (!user) {
    ycShowAlert("loginAlert", "Compte introuvable. Crée un compte d’abord.", "error");
    return;
  }

  if (user.status === "pending_admin") {
    ycShowAlert(
      "loginAlert",
      "Ton compte est en attente de validation admin (email non @ynov.com).",
      "info"
    );
    return;
  }

  if (user.status !== "active") {
    ycShowAlert("loginAlert", "Compte désactivé ou non autorisé.", "error");
    return;
  }

  if (user.password !== password) {
    ycShowAlert("loginAlert", "Mot de passe incorrect.", "error");
    return;
  }

  // Campus utilisé pour MON.YNOV (déterminé au login comme demandé)
  user.campus = campus;
  ycSetUsers(users);

  ycSetSession({ userId: user.id, campus, createdAt: ycNowIso() });
  ycShowAlert("loginAlert", "Connexion réussie. Redirection…", "success");
  setTimeout(() => (window.location.href = "index.html"), 500);
}

function ycGetCurrentUser() {
  const session = ycGetSession();
  if (!session?.userId) return null;
  const users = ycGetUsers();
  return users.find((u) => u.id === session.userId) || null;
}

function ycPopulateCampusSelect(selectEl, preferredValue) {
  if (!selectEl) return;
  if (selectEl.dataset.populated === "true") return;
  selectEl.dataset.populated = "true";

  for (const c of YC_CAMPUSES_FR) {
    const opt = document.createElement("option");
    opt.value = c;
    opt.textContent = c;
    selectEl.appendChild(opt);
  }

  if (preferredValue) {
    selectEl.value = preferredValue;
  }
}

function ycRequireAuth() {
  const requiresAuth = document.body?.dataset?.requiresAuth === "true";
  if (!requiresAuth) return;

  const session = ycGetSession();
  if (session?.userId) return;

  const here = window.location.pathname.split("/").pop() || "index.html";
  window.location.href = `login.html?next=${encodeURIComponent(here)}`;
}

// =========================================================
// Chats (MON.YNOV campus + FRANCE global) - front-only
// =========================================================

function ycChatKeyForRoom(room, campusName) {
  if (room === "france") return "yc_chat_france_v1";
  const safe = String(campusName || "Campus")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return `yc_chat_campus_${safe}_v1`;
}

function ycChatLoad(room, campusName) {
  return ycLoadJson(ycChatKeyForRoom(room, campusName), []);
}

function ycChatSave(room, campusName, messages) {
  ycSaveJson(ycChatKeyForRoom(room, campusName), messages);
}

function ycFormatTimeShort(iso) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" });
}

function ycRenderRoom(room) {
  const user = ycGetCurrentUser();
  const session = ycGetSession();
  const campus = session?.campus || user?.campus || "Paris Ynov Campus";

  const chatMessages = document.getElementById("chatMessages");
  if (!chatMessages) return;
  chatMessages.innerHTML = "";

  const hist = ycChatLoad(room, campus);
  if (!Array.isArray(hist) || hist.length === 0) {
    const empty = document.createElement("div");
    empty.className = "message-bubble received";
    empty.innerText =
      room === "france"
        ? "Bienvenue dans le salon FRANCE. Lance la conversation !"
        : `Bienvenue dans MON.YNOV (${campus}). Lance la conversation !`;
    chatMessages.appendChild(empty);
  } else {
    for (const m of hist) {
      const div = document.createElement("div");
      const isMe = m?.userId && user?.id && m.userId === user.id;
      div.className = `message-bubble ${isMe ? "sent" : "received"}`;
      div.innerText = m?.text || "";
      chatMessages.appendChild(div);
    }
  }

  // Header
  const chatTitle = document.getElementById("chatTitle");
  const chatSubtitle = document.getElementById("chatSubtitle");
  const chatAvatar = document.getElementById("chatAvatar");
  const tabCampusName = document.getElementById("tabCampusName");

  if (tabCampusName) tabCampusName.textContent = campus;

  if (room === "france") {
    if (chatTitle) chatTitle.textContent = "France";
    if (chatSubtitle) chatSubtitle.textContent = "Salon global Ynov";
    if (chatAvatar) chatAvatar.textContent = "FR";
  } else {
    if (chatTitle) chatTitle.textContent = "Mon Ynov";
    if (chatSubtitle) chatSubtitle.textContent = campus;
    if (chatAvatar) chatAvatar.textContent = (campus || "Y").slice(0, 1).toUpperCase();
  }

  // Active styles
  const convCampus = document.getElementById("convCampus");
  const convFrance = document.getElementById("convFrance");
  if (convCampus && convFrance) {
    convCampus.classList.toggle("active-conversation", room !== "france");
    convFrance.classList.toggle("active-conversation", room === "france");
  }

  // Times in list
  const lastCampus = ycChatLoad("campus", campus).slice(-1)[0];
  const lastFrance = ycChatLoad("france", campus).slice(-1)[0];
  const convCampusTime = document.getElementById("convCampusTime");
  const convFranceTime = document.getElementById("convFranceTime");
  if (convCampusTime) convCampusTime.textContent = ycFormatTimeShort(lastCampus?.at);
  if (convFranceTime) convFranceTime.textContent = ycFormatTimeShort(lastFrance?.at);

  // Title in list
  const convCampusTitle = document.getElementById("convCampusTitle");
  if (convCampusTitle) convCampusTitle.textContent = `Mon.ynov • ${campus}`;

  // Avatar in list
  const convCampusAvatar = document.getElementById("convCampusAvatar");
  if (convCampusAvatar) convCampusAvatar.textContent = (campus || "Y").slice(0, 1).toUpperCase();

  // Persist current room
  localStorage.setItem("yc_current_room_v1", room);
}

function ycGetCurrentRoom() {
  const raw = localStorage.getItem("yc_current_room_v1");
  return raw === "france" ? "france" : "campus";
}

function ycInitMessagesPage() {
  if ((window.location.pathname.split("/").pop() || "").toLowerCase() !== "messages.html") return;

  // Permet d'ouvrir directement un salon via URL: messages.html?room=campus|france
  const roomParam = new URLSearchParams(window.location.search).get("room");
  if (roomParam === "france" || roomParam === "campus") {
    localStorage.setItem("yc_current_room_v1", roomParam);
  }

  const tabCampus = document.getElementById("tabCampus");
  const tabFrance = document.getElementById("tabFrance");
  const convCampus = document.getElementById("convCampus");
  const convFrance = document.getElementById("convFrance");

  tabCampus?.addEventListener("click", () => ycRenderRoom("campus"));
  tabFrance?.addEventListener("click", () => ycRenderRoom("france"));
  convCampus?.addEventListener("click", () => ycRenderRoom("campus"));
  convFrance?.addEventListener("click", () => ycRenderRoom("france"));

  ycRenderRoom(ycGetCurrentRoom());
}

function ycSendRoomMessage(event) {
  event.preventDefault();
  const input = document.getElementById("messageInput");
  if (!input) return;
  const text = input.value.trim();
  if (!text) return;

  const user = ycGetCurrentUser();
  const session = ycGetSession();
  const campus = session?.campus || user?.campus || "Paris Ynov Campus";
  const room = ycGetCurrentRoom();

  const hist = ycChatLoad(room, campus);
  const messages = Array.isArray(hist) ? hist : [];
  messages.push({ userId: user?.id || null, text, at: ycNowIso() });
  ycChatSave(room, campus, messages);
  input.value = "";
  ycRenderRoom(room);
}

// =========================================================
// Bot IA (front-only) - connecté à l'utilisateur + historique
// =========================================================

const YC_CHAT_KEY = "yc_bot_chat_v1";

function ycBotLoadHistory() {
  return ycLoadJson(YC_CHAT_KEY, null);
}

function ycBotSaveHistory(messages) {
  ycSaveJson(YC_CHAT_KEY, messages);
}

function ycBotAppendBubble(container, role, text) {
  const div = document.createElement("div");
  div.className = role === "user" ? "user-message" : "bot-message";
  div.innerText = text;
  container.appendChild(div);
  container.scrollTop = container.scrollHeight;
}

function ycBotRenderHistoryIfAny() {
  const chat = document.getElementById("chatContainer");
  if (!chat) return;

  const hist = ycBotLoadHistory();
  if (!hist || !Array.isArray(hist) || hist.length === 0) return;

  chat.innerHTML = "";
  for (const m of hist) {
    if (!m?.role || typeof m?.text !== "string") continue;
    ycBotAppendBubble(chat, m.role, m.text);
  }
}

function ycBotSeedGreetingIfEmpty() {
  const chat = document.getElementById("chatContainer");
  if (!chat) return;

  const existing = ycBotLoadHistory();
  if (Array.isArray(existing) && existing.length > 0) return;

  const user = ycGetCurrentUser();
  const name = user?.displayName ? user.displayName.split(" ")[0] : "toi";
  const greeting =
    `Salut ${name} ! Je suis le bot YConnect.\n` +
    `Je peux t’aider pour :\n` +
    `- résumé de profil\n` +
    `- idées de projet\n` +
    `- conseils\n\n` +
    `Essaye: "résumé profil" ou "idée projet".`;

  const seed = [{ role: "bot", text: greeting, at: ycNowIso() }];
  ycBotSaveHistory(seed);
  ycBotRenderHistoryIfAny();
}

function ycBotReply(text) {
  const user = ycGetCurrentUser();
  const email = user?.email || "";
  const username = user?.username || "";
  const displayName = user?.displayName || "Utilisateur";

  const t = String(text || "").toLowerCase();

  if (t.includes("résumé") || t.includes("resume") || t.includes("profil")) {
    return (
      `Résumé de ton profil :\n` +
      `- Nom: ${displayName}\n` +
      `- Username: ${username || "—"}\n` +
      `- Email: ${email || "—"}\n\n` +
      `Conseil: ajoute tes compétences et 1-2 projets pour améliorer ta visibilité.`
    );
  }

  if (t.includes("idée") || t.includes("idee") || t.includes("projet")) {
    return (
      `3 idées rapides de projet Ynov :\n` +
      `1) Mini “YMatch” : matching étudiants ↔ projets (compétences + disponibilités)\n` +
      `2) Agenda campus : événements + RSVP + rappels\n` +
      `3) Groupe de travail : posts privés par groupe + fichiers + tâches\n\n` +
      `Dis-moi ton niveau (B1/B2/B3) et ton stack, je te propose une idée plus ciblée.`
    );
  }

  if (t.includes("connexion") || t.includes("login") || t.includes("compte")) {
    return (
      `Côté front, tu as :\n` +
      `- Inscription @ynov.com => accès immédiat\n` +
      `- Autre email => demande admin (en attente)\n\n` +
      `Pour une vraie prod: il faudra un backend + hash mot de passe + sessions.`
    );
  }

  return `Je peux t’aider sur: "résumé profil", "idée projet", "conseils". Tu veux quoi ?`;
}

function sendMessage(event) {
  event.preventDefault();

  const input = document.getElementById("userInput");
  const chat = document.getElementById("chatContainer");
  if (!input || !chat) return;

  const text = input.value.trim();
  if (text === "") return;

  const hist = ycBotLoadHistory();
  const messages = Array.isArray(hist) ? hist : [];
  messages.push({ role: "user", text, at: ycNowIso() });

  ycBotAppendBubble(chat, "user", text);
  input.value = "";

  const reply = ycBotReply(text);
  messages.push({ role: "bot", text: reply, at: ycNowIso() });
  ycBotSaveHistory(messages);

  setTimeout(() => ycBotAppendBubble(chat, "bot", reply), 120);
}

document.addEventListener("DOMContentLoaded", () => {
  ycRequireAuth();

  // Campus selects (login/register)
  const currentUser = ycGetCurrentUser();
  const session = ycGetSession();
  const preferredCampus = session?.campus || currentUser?.campus || "";
  ycPopulateCampusSelect(document.getElementById("regCampus"), preferredCampus);
  ycPopulateCampusSelect(document.getElementById("loginCampus"), preferredCampus);

  // Si on est sur la page bot, on connecte l'UI à l'utilisateur + historique
  if ((window.location.pathname.split("/").pop() || "").toLowerCase() === "bot.html") {
    ycBotRenderHistoryIfAny();
    ycBotSeedGreetingIfEmpty();
  }

  // 2 chats: campus + france
  ycInitMessagesPage();
});
