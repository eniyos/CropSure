#!/usr/bin/env python3
"""
CropSure - Patentability, Novelty Assessment & IP Strategy PDF Generator
Generates a comprehensive, professional PDF report evaluating whether CropSure
can be patented, analyzing prior art, patent eligibility, and filing strategies.
"""

import os
import sys
from pathlib import Path
from datetime import datetime

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
    KeepTogether,
    HRFlowable,
)
from reportlab.pdfgen import canvas

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_PDF = PROJECT_ROOT / "CropSure_Patentability_and_Novelty_Report.pdf"


class NumberedCanvas(canvas.Canvas):
    """Two-pass canvas for dynamic total page count and professional headers/footers."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))

        # Running Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(
                54,
                11 * inch - 36,
                "CropSure — Patentability, Novelty Assessment & IP Strategy Report",
            )
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(54, 11 * inch - 42, 8.5 * inch - 54, 11 * inch - 42)

        # Running Footer
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(8.5 * inch - 54, 34, page_text)
        self.drawString(
            54,
            34,
            "Privileged & Confidential — Intellectual Property Legal-Technical Assessment",
        )
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 46, 8.5 * inch - 54, 46)

        self.restoreState()


def build_pdf():
    print(f"[PDF GENERATION] Compiling patentability report: {OUTPUT_PDF}")

    doc = SimpleDocTemplate(
        str(OUTPUT_PDF),
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54,
    )

    styles = getSampleStyleSheet()

    # Color definitions
    primary_color = colors.HexColor("#0F172A")    # Deep Navy
    secondary_color = colors.HexColor("#1E3A8A")  # Royal Slate
    accent_green = colors.HexColor("#065F46")     # Forest Green
    accent_red = colors.HexColor("#991B1B")       # Deep Crimson
    accent_amber = colors.HexColor("#92400E")     # Dark Amber
    card_bg = colors.HexColor("#F8FAFC")
    border_color = colors.HexColor("#E2E8F0")

    title_style = ParagraphStyle(
        "CoverTitle",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=23,
        leading=28,
        textColor=primary_color,
        spaceAfter=5,
    )

    subtitle_style = ParagraphStyle(
        "CoverSubtitle",
        parent=styles["Normal"],
        fontName="Helvetica",
        fontSize=11.5,
        leading=16,
        textColor=secondary_color,
        spaceAfter=12,
    )

    h1_style = ParagraphStyle(
        "Heading1_Custom",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=14,
        leading=18,
        textColor=primary_color,
        spaceBefore=14,
        spaceAfter=7,
        keepWithNext=True,
    )

    h2_style = ParagraphStyle(
        "Heading2_Custom",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=10.5,
        leading=14.5,
        textColor=secondary_color,
        spaceBefore=9,
        spaceAfter=4,
        keepWithNext=True,
    )

    body_style = ParagraphStyle(
        "Body_Custom",
        parent=styles["Normal"],
        fontName="Helvetica",
        fontSize=9,
        leading=13,
        textColor=colors.HexColor("#334155"),
        spaceAfter=6,
    )

    bullet_style = ParagraphStyle(
        "Bullet_Custom",
        parent=body_style,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=3.5,
    )

    table_cell = ParagraphStyle(
        "TableCell",
        parent=styles["Normal"],
        fontName="Helvetica",
        fontSize=8,
        leading=11,
        textColor=colors.HexColor("#1E293B"),
    )

    table_header = ParagraphStyle(
        "TableHeader",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=8,
        leading=11,
        textColor=colors.white,
    )

    code_style = ParagraphStyle(
        "CodeStyle",
        parent=styles["Normal"],
        fontName="Courier",
        fontSize=7.5,
        leading=10,
        textColor=colors.HexColor("#0F172A"),
    )

    story = []

    # =========================================================================
    # 1. HEADER SECTION
    # =========================================================================
    story.append(Paragraph("CropSure: Novelty Assessment & Patentability Report", title_style))
    story.append(Paragraph("Legal-Technical Feasibility Analysis Under US, Indian, and International Patent Laws", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=primary_color, spaceBefore=0, spaceAfter=10))

    # Metadata Table
    meta_data = [
        [
            Paragraph("<b>Subject Project:</b> CropSure Agricultural AI & Trust Platform", table_cell),
            Paragraph(f"<b>Assessment Date:</b> {datetime.now().strftime('%B %d, %Y')}", table_cell),
        ],
        [
            Paragraph("<b>Target Invention:</b> Multi-Modal Agro-Telemetry, Edge Triage & Trust System", table_cell),
            Paragraph("<b>Patent Eligibility:</b> <b>PATENTABLE (As a Unified System/Method)</b>", table_cell),
        ],
    ]
    meta_table = Table(meta_data, colWidths=[3.7 * inch, 3.3 * inch])
    meta_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F1F5F9")),
        ("PADDING", (0, 0), (-1, -1), 5),
        ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))

    # =========================================================================
    # 2. EXECUTIVE SUMMARY & VERDICT
    # =========================================================================
    story.append(Paragraph("1. Executive Summary & Core Verdict", h1_style))

    summary_text = (
        "<b>CORE VERDICT:</b><br/>"
        "<b>1. Can this be patented? YES, CONDITIONALLY.</b> CropSure can be patented as a <b>System and Computer-Implemented "
        "Method</b> claiming the closed-loop combination of anti-spoofing sensor telemetry, edge-adaptive diagnostic triage, "
        "and dynamic Bayesian trust calculation tied to digital agricultural asset verification.<br/>"
        "<b>2. Can individual ML algorithms be patented? NO.</b> Off-the-shelf neural architectures (ResNet/YOLO trained on PlantVillage), "
        "standard Grad-CAM, Van der Plank differential equations, and textbook scikit-learn models are <b>strictly unpatentable</b> "
        "due to extensive prior art and statutory software/mathematics exclusions (Section 3(k) in India, 35 U.S.C. § 101 in the US).<br/>"
        "<b>3. CRITICAL ACTION REQUIRED:</b> The public availability of the code at <code>github.com/Ritesh7365/CropSure</code> "
        "poses an immediate threat under the global <b>Absolute Novelty</b> doctrine. To preserve patent rights, the repository "
        "must be made private immediately until a <b>Provisional Patent Application</b> is filed."
    )

    verdict_card = Table([[Paragraph(summary_text, body_style)]], colWidths=[7.0 * inch])
    verdict_card.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#FEF3C7")),
        ("BORDER", (0, 0), (-1, -1), 1, colors.HexColor("#D97706")),
        ("PADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(verdict_card)
    story.append(Spacer(1, 10))

    # =========================================================================
    # 3. PRIOR ART & NOVELTY MATRIX
    # =========================================================================
    story.append(Paragraph("2. Granular Novelty & Prior Art Matrix", h1_style))
    story.append(Paragraph(
        "Patent examiners perform a prior art search across global patent databases (WIPO, USPTO, EPO) and academic literature. "
        "The following table distinguishes what is public prior art versus what constitutes patentable subject matter in CropSure:",
        body_style,
    ))

    matrix_data = [
        [Paragraph("Component / Pipeline", table_header), Paragraph("Underlying Technique", table_header), Paragraph("Prior Art Status", table_header), Paragraph("Patentability Assessment", table_header)],
        [
            Paragraph("<b>Model 1: Leaf Disease Detection</b>", table_cell),
            Paragraph("ResNet-18 / YOLOv8 trained on PlantVillage corpus (8 classes)", table_cell),
            Paragraph("<b>Extensively Published</b><br/>Thousands of papers since 2015 (Mohanty et al., Hughes & Salathé).", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE ALONE</b></font><br/>Standard computer vision application on public data.", table_cell),
        ],
        [
            Paragraph("<b>Model 2: Disease Simulator</b>", table_cell),
            Paragraph("Van der Plank delay-differential infection equations", table_cell),
            Paragraph("<b>Textbook Literature</b><br/>Published in 1963 by J.E. Van der Plank; foundational epidemiology.", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE</b></font><br/>Excluded as a natural law / pure mathematical algorithm.", table_cell),
        ],
        [
            Paragraph("<b>Model 3: Bi-LSTM Forecaster</b>", table_cell),
            Paragraph("Recurrent network with Monte Carlo Dropout (50 stochastic passes)", table_cell),
            Paragraph("<b>Established ML Method</b><br/>Gal & Ghahramani (2016). Applied to agricultural time series in prior papers.", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE ALONE</b></font><br/>Conventional application of uncertainty estimation.", table_cell),
        ],
        [
            Paragraph("<b>Model 4: Grad-CAM Saliency</b>", table_cell),
            Paragraph("Gradient backpropagation to layer4 activation maps", table_cell),
            Paragraph("<b>Standard Prior Art</b><br/>Selvaraju et al. (ICCV 2017). Applied to leaves across literature 2018–2024.", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE ALONE</b></font><br/>Widely utilized explainability technique.", table_cell),
        ],
        [
            Paragraph("<b>Model 5: Yield-Loss Regressor</b>", table_cell),
            Paragraph("Random Forest regressing AUDPC, phenology, VPD to yield loss", table_cell),
            Paragraph("<b>Conventional Agronomy</b><br/>AUDPC (Shaner & Finney 1977) + scikit-learn standard regression.", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE ALONE</b></font><br/>Statistical regression on known agronomic metrics.", table_cell),
        ],
        [
            Paragraph("<b>Model 6: Bayesian Trust Engine</b>", table_cell),
            Paragraph("Beta-Conjugate updating with 12 decaying evidence signals", table_cell),
            Paragraph("<b>Known Framework</b><br/>Beta reputation systems (Jøsang 2002) applied to sensor networks.", table_cell),
            Paragraph("<font color='#DC2626'><b>NOT PATENTABLE ALONE</b></font><br/>Mathematical method / abstract statistical updating.", table_cell),
        ],
        [
            Paragraph("<b>Unified Closed-Loop System & Method</b>", table_cell),
            Paragraph("Dynamic integration of edge anti-spoofing, entropy-based triage, Bayesian trust, and crop passport", table_cell),
            Paragraph("<b>Novel Combination</b><br/>No prior art combines physical sensor validation, edge-cloud split triage, and parametric crop trust.", table_cell),
            Paragraph("<font color='#065F46'><b>PATENTABLE AS A SYSTEM</b></font><br/>Solves tangible technical problems (fraud, latency, parametric underwriting).", table_cell),
        ],
    ]

    matrix_table = Table(matrix_data, colWidths=[1.4 * inch, 1.8 * inch, 1.8 * inch, 2.0 * inch])
    matrix_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), primary_color),
        ("GRID", (0, 0), (-1, -1), 0.5, border_color),
        ("PADDING", (0, 0), (-1, -1), 4.5),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -2), [colors.white, card_bg]),
        ("BACKGROUND", (0, -1), (-1, -1), colors.HexColor("#ECFDF5")),
    ]))
    story.append(matrix_table)
    story.append(Spacer(1, 10))

    # =========================================================================
    # 4. STATUTORY PATENT CRITERIA & JURISDICTIONS
    # =========================================================================
    story.append(Paragraph("3. Statutory Requirements Across Major Jurisdictions", h1_style))

    story.append(Paragraph("A. United States (USPTO — 35 U.S.C. § 101 & Alice/Mayo Test)", h2_style))
    story.append(Paragraph(
        "Under the landmark <i>Alice Corp. v. CLS Bank</i> decision, abstract algorithmic ideas are non-patentable unless an "
        "<b>inventive concept</b> ('significantly more') transforms them into patent-eligible applications. "
        "To satisfy § 101, CropSure must be framed around <b>improvements in edge computing efficiency</b> "
        "(quantized TFLite triage preventing cloud bottlenecking) and <b>hardware-coupled anti-fraud telemetry verification</b>.",
        body_style,
    ))

    story.append(Paragraph("B. India (Indian Patent Office — Section 3(k) of Patents Act 1970)", h2_style))
    story.append(Paragraph(
        "Section 3(k) strictly excludes 'a mathematical or business method or a computer programme per se or algorithms'. "
        "However, under current IPO Computer-Related Inventions (CRI) Guidelines, software coupled with hardware that produces a "
        "<b>demonstrable technical effect</b> (e.g., optical sensor anti-spoofing, real-time edge processing) is eligible for patent grant.",
        body_style,
    ))

    story.append(Paragraph("C. Europe (European Patent Office — Article 52(2)/(3) EPC)", h2_style))
    story.append(Paragraph(
        "The EPO applies the 'problem-solution approach'. The mathematical models must contribute to the technical character of "
        "an invention that solves a specific technical problem outside of pure data analysis.",
        body_style,
    ))
    story.append(Spacer(1, 8))

    # =========================================================================
    # 5. URGENT ALERT: PUBLIC GITHUB REPOSITORY
    # =========================================================================
    story.append(Paragraph("4. Critical Urgency: Public GitHub Repository Exposure", h1_style))

    alert_text = (
        "<b>⚠️ CRITICAL INTELLECTUAL PROPERTY WARNING:</b><br/>"
        "Under patent law in India, the European Union, the United Kingdom, and all PCT signatory countries, "
        "the doctrine of <b>ABSOLUTE NOVELTY</b> applies. Any public disclosure made anywhere in the world prior to the official "
        "filing date completely destroys patent novelty.<br/><br/>"
        "Because the repository <code>https://github.com/Ritesh7365/CropSure</code> is currently public on the internet: "
        "<br/>• A patent examiner can cite your own public commit history, documentation, and source code against your application."
        "<br/>• While the US has a 12-month inventor grace period (35 U.S.C. § 102(b)), relying on this forfeits patent protection in Europe, India, and Asia."
        "<br/><br/><b>MANDATORY NEXT STEP:</b> Make the GitHub repository <b>PRIVATE immediately</b> until a Provisional Patent Application has been officially filed."
    )

    alert_card = Table([[Paragraph(alert_text, body_style)]], colWidths=[7.0 * inch])
    alert_card.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#FEF2F2")),
        ("BORDER", (0, 0), (-1, -1), 1.5, accent_red),
        ("PADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(alert_card)
    story.append(Spacer(1, 10))

    # =========================================================================
    # 6. HOW TO FRAME THE PATENT CLAIMS
    # =========================================================================
    story.append(Paragraph("5. Proposed Patent Claim Architecture", h1_style))
    story.append(Paragraph(
        "To maximize defensibility and grant probability, patent counsel should frame the claims around the following three inventive anchors:",
        body_style,
    ))

    claims_data = [
        [Paragraph("Claim Level", table_header), Paragraph("Invention Focus", table_header), Paragraph("Technical Anchor / Non-Obvious Element", table_header)],
        [
            Paragraph("<b>Independent Claim 1 (System)</b>", table_cell),
            Paragraph("Multi-Modal Anti-Spoofing & Parametric Agricultural Verification", table_cell),
            Paragraph("A physical system comprising an edge imaging terminal, geolocation receiver, and verification server configured to cross-validate physical capture telemetry against biological disease latency before admitting imagery to inference.", table_cell),
        ],
        [
            Paragraph("<b>Independent Claim 2 (Method)</b>", table_cell),
            Paragraph("Adaptive Edge-to-Cloud Distributed Diagnostic Triage", table_cell),
            Paragraph("A computer-implemented method wherein low-power quantized edge inference (TFLite) adaptively triggers remote stochastic uncertainty passes (MC Dropout) and gradient backpropagation (Grad-CAM) only when local prediction entropy exceeds an adaptive boundary.", table_cell),
        ],
        [
            Paragraph("<b>Dependent Claims (3–10)</b>", table_cell),
            Paragraph("Parametric Risk Underwriting & Blockchain Issuance", table_cell),
            Paragraph("Coupling time-decayed Bayesian Beta-conjugate distributions with Van der Plank epidemiological ODE projections to autonomously trigger parametric crop insurance payouts and issue tamper-proof digital passports.", table_cell),
        ],
    ]

    claims_table = Table(claims_data, colWidths=[1.8 * inch, 2.0 * inch, 3.2 * inch])
    claims_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), secondary_color),
        ("GRID", (0, 0), (-1, -1), 0.5, border_color),
        ("PADDING", (0, 0), (-1, -1), 5),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, card_bg]),
    ]))
    story.append(claims_table)
    story.append(Spacer(1, 10))

    # =========================================================================
    # 7. MULTI-LAYER IP PROTECTION STRATEGY & ROADMAP
    # =========================================================================
    story.append(Paragraph("6. Multi-Layered Intellectual Property Strategy", h1_style))
    story.append(Paragraph(
        "Patents should not stand alone. A commercial venture must implement a 4-pillar IP defense strategy:",
        body_style,
    ))

    ip_pillars = [
        "<b>1. Patent (System & Method):</b> Protects the overall technical architecture, the edge-cloud triage mechanism, and anti-spoofing verification method against competitors reproducing the functionality.",
        "<b>2. Copyright (Source Code & UI):</b> Automatically protects the literal Dart Flutter codebase, Python backend scripts, and UI asset designs against unauthorized copying or scraping.",
        "<b>3. Trade Secrets (Weights & Datasets):</b> Keep the proprietary fine-tuned model checkpoints (<code>tomato_disease_classifier.pth</code>), curated hyperparameter configs, and internal sensor thresholds hosted securely on backend servers.",
        "<b>4. Trademark (Brand & Logo):</b> Register the brand mark <b>'CropSure'</b> and logo in target agricultural jurisdictions to establish commercial exclusivity.",
    ]

    for p in ip_pillars:
        story.append(Paragraph(p, bullet_style))

    story.append(Spacer(1, 10))

    # Action Roadmap
    roadmap_box = (
        "<b>RECOMMENDED ACTION ROADMAP:</b><br/>"
        "<b>Week 1:</b> Make <code>github.com/Ritesh7365/CropSure</code> private to halt public prior art accrual.<br/>"
        "<b>Month 1:</b> File a <b>Provisional Patent Application</b> focusing on the combined Edge-Cloud Triage and Anti-Spoofing Telemetry System.<br/>"
        "<b>Months 2–12:</b> With 'Patent Pending' status secured, publish the repository, demonstrate to partners, and run field pilot testing.<br/>"
        "<b>Month 12:</b> File a Complete Patent Specification and PCT International Application targeting major agricultural markets."
    )

    roadmap_table = Table([[Paragraph(roadmap_box, body_style)]], colWidths=[7.0 * inch])
    roadmap_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
        ("BORDER", (0, 0), (-1, -1), 1.5, primary_color),
        ("PADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(roadmap_table)

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"[SUCCESS] Patentability report built: {OUTPUT_PDF} ({OUTPUT_PDF.stat().st_size / 1024:.1f} KB)")


if __name__ == "__main__":
    build_pdf()
