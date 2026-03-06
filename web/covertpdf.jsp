<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Convertisseur Express | Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.4.2/mammoth.browser.min.js"></script>
    <style>
        .action-buttons { display: none; margin-top: 15px; gap: 10px; flex-wrap: wrap; }
        .btn-share { padding: 8px 12px; border-radius: 6px; border: none; cursor: pointer; color: white; font-weight: 600; text-decoration: none; font-size: 0.85rem; display: inline-block; }
        .whatsapp { background: #25D366; }
        .telegram { background: #0088cc; }
        .download { background: #4f46e5; }
        .docx-preview { padding: 20px; background: white; overflow-y: auto; height: 100%; font-family: 'Times New Roman', serif; line-height: 1.6; }
        .excel-preview { padding: 20px; background: white; overflow: auto; height: 100%; }
        .excel-preview table { border-collapse: collapse; width: 100%; }
        .excel-preview th, .excel-preview td { border: 1px solid #ccc; padding: 6px 10px; font-size: 0.85rem; }
        .excel-preview th { background: #f0f0f0; font-weight: bold; }
    </style>
</head>
<body>
    <div class="split-view">
        <aside class="controls-section">
            <h2>Convertisseur Express</h2>

            <%-- Affichage des erreurs serveur si existantes --%>
            <% String erreur = (String) request.getAttribute("erreur"); %>
            <% if (erreur != null) { %>
                <div style="color:red; background:#fee; padding:10px; border-radius:6px; margin-bottom:10px;">⚠️ <%= erreur %></div>
            <% } %>

            <form id="uploadForm" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Choisir votre fichier :</label>
                    <input type="file" name="fileInput" id="fileInput" required accept=".pdf,.docx,.doc,.xlsx,.xls" />
                </div>
                <div class="form-group">
                    <label>Format cible</label>
                    <select name="formatCible" id="formatCible">
                        <option value="pdf">Word → PDF</option>
                        <option value="docx">PDF → Word</option>
                        <option value="xlsx">PDF → Excel</option>
                    </select>
                </div>
                <button type="submit" class="btn-primary" id="btnConvertir">Convertir maintenant</button>
            </form>

            <div id="loaderContainer" class="loader-container" style="display: none; margin-top: 20px;">
                <div class="spinner"></div>
                <p id="statusText">Conversion en cours...</p>
                <div class="progress-bar-bg">
                    <div id="progressBar" class="progress-bar-fill" style="width: 0%; transition: width 0.4s ease;"></div>
                </div>
            </div>

            <div id="shareSection" class="action-buttons">
                <p style="width: 100%; font-weight: bold; margin-bottom: 5px;">Résultat :</p>
                <a href="#" id="dlLink" class="btn-share download" download> Télécharger</a>
                <a href="#" id="waLink" class="btn-share whatsapp" target="_blank"> WhatsApp</a>
                <a href="#" id="tgLink" class="btn-share telegram" target="_blank">️ Telegram</a>
            </div>
        </aside>

        <main class="preview-section">
            <header class="preview-header"><span id="nomFichier">Aperçu du document converti</span></header>
            <div id="previewBody" class="preview-body">
                <div class="empty-state"><p>L'aperçu apparaîtra ici après conversion.</p></div>
            </div>
        </main>
    </div>

    <script>
        // Variables globales
        let convertedBlob = null;
        let convertedFileName = "document_converti";
        let progressInterval = null;

        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const fileInput = document.getElementById('fileInput');
            const format = document.getElementById('formatCible').value;

            if (!fileInput.files || fileInput.files.length === 0) {
                alert("Veuillez sélectionner un fichier.");
                return;
            }

            const formData = new FormData(this);
            const btn = document.getElementById('btnConvertir');
            const loader = document.getElementById('loaderContainer');
            const bar = document.getElementById('progressBar');
            const statusText = document.getElementById('statusText');
            const shareSection = document.getElementById('shareSection');

            // Reset UI
            shareSection.style.display = 'none';
            document.getElementById('previewBody').innerHTML = '<div class="empty-state"><p>Conversion en cours...</p></div>';
            loader.style.display = 'block';
            btn.disabled = true;
            bar.style.width = '0%';

            // Animation de la barre de progression
            let progress = 0;
            progressInterval = setInterval(function() {
                if (progress < 85) {
                    progress += Math.random() * 10;
                    bar.style.width = Math.min(progress, 85) + '%';
                }
            }, 400);

            statusText.textContent = 'Envoi du fichier...';

            fetch('ConversionServlet', { method: 'POST', body: formData })
            .then(function(response) {
                if (!response.ok) {
                    return response.text().then(function(text) {
                        throw new Error(text || 'Erreur serveur : ' + response.status);
                    });
                }
                statusText.textContent = 'Traitement en cours...';
                // Récupérer le nom de fichier depuis les headers si disponible
                const disposition = response.headers.get('Content-Disposition');
                if (disposition) {
                    const match = disposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
                    if (match) convertedFileName = match[1].replace(/['"]/g, '');
                }
                return response.blob();
            })
            .then(function(blob) {
                clearInterval(progressInterval);
                bar.style.width = '100%';
                statusText.textContent = 'Conversion terminée !';

                convertedBlob = blob;
                const url = URL.createObjectURL(blob);

                // Nommer le fichier téléchargé
                const ext = format === 'pdf' ? 'pdf' : (format === 'docx' ? 'docx' : 'xlsx');
                const dlName = convertedFileName.endsWith('.' + ext) ? convertedFileName : convertedFileName + '.' + ext;
                document.getElementById('nomFichier').textContent = dlName;

                // === APERÇU SELON LE FORMAT ===
                if (format === 'pdf') {
                    // Aperçu PDF natif via iframe
                    document.getElementById('previewBody').innerHTML =
                        '<iframe src="' + url + '#toolbar=1" width="100%" height="100%" style="border:none;"></iframe>';

                } else if (format === 'docx') {
                    // Aperçu Word via Mammoth.js
                    statusText.textContent = 'Chargement de l\'aperçu Word...';
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        const arrayBuffer = e.target.result;
                        mammoth.convertToHtml({ arrayBuffer: arrayBuffer })
                        .then(function(result) {
                            document.getElementById('previewBody').innerHTML =
                                '<div class="docx-preview">' + result.value + '</div>';
                            if (result.messages.length > 0) {
                                console.warn('Mammoth warnings:', result.messages);
                            }
                        })
                        .catch(function(err) {
                            document.getElementById('previewBody').innerHTML =
                                '<div class="empty-state"><p>✅ Conversion réussie.<br>Aperçu non disponible pour ce fichier.<br>Veuillez le télécharger.</p></div>';
                        });
                    };
                    reader.readAsArrayBuffer(blob);

                } else if (format === 'xlsx') {
                    // Aperçu Excel via SheetJS
                    statusText.textContent = 'Chargement de l\'aperçu Excel...';
                    const script = document.createElement('script');
                    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js';
                    script.onload = function() {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            try {
                                const data = new Uint8Array(e.target.result);
                                const workbook = XLSX.read(data, { type: 'array' });
                                const sheetName = workbook.SheetNames[0];
                                const sheet = workbook.Sheets[sheetName];
                                const html = XLSX.utils.sheet_to_html(sheet, { editable: false });
                                document.getElementById('previewBody').innerHTML =
                                    '<div class="excel-preview">' + html + '</div>';
                            } catch(err) {
                                document.getElementById('previewBody').innerHTML =
                                    '<div class="empty-state"><p>✅ Conversion réussie.<br>Aperçu non disponible.<br>Veuillez télécharger le fichier.</p></div>';
                            }
                        };
                        reader.readAsArrayBuffer(blob);
                    };
                    document.head.appendChild(script);
                }

                // === BOUTONS PARTAGE & TÉLÉCHARGEMENT ===
                shareSection.style.display = 'flex';

                // Lien téléchargement direct
                const dlLink = document.getElementById('dlLink');
                dlLink.href = url;
                dlLink.setAttribute('download', dlName);

                // WhatsApp & Telegram : partage du lien de la page (fichier local non partageable directement)
                const shareMsg = encodeURIComponent(
    '📄 J\'ai converti mon document "' + dlName + '" avec Convertisseur Express !\n' +
    '🔗 Essayez-le ici : https://convertisseur-express.com'
);

// ✅ WhatsApp : api.whatsapp.com fonctionne sur mobile ET desktop
document.getElementById('waLink').href = 'https://api.whatsapp.com/send?text=' + shareMsg;

// ✅ Telegram : on partage un vrai message utile (pas une URL localhost)
document.getElementById('tgLink').href = 'https://t.me/share/url?url=' +
    encodeURIComponent('https://convertisseur-express.com') +
    '&text=' + shareMsg;

                loader.style.display = 'none';
                btn.disabled = false;
            })
            .catch(function(err) {
                clearInterval(progressInterval);
                loader.style.display = 'none';
                btn.disabled = false;
                bar.style.width = '0%';
                document.getElementById('previewBody').innerHTML =
                    '<div class="empty-state" style="color:red;"><p>❌ Erreur : ' + err.message + '</p></div>';
                alert('Erreur lors de la conversion : ' + err.message);
            });
        });
    </script>
</body>
</html>
