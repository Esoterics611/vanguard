const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, 
        Header, Footer, AlignmentType, PageOrientation, LevelFormat, 
        HeadingLevel, BorderStyle, WidthType, ShadingType,
        VerticalAlign, PageNumber, PageBreak, Tab, TabStopType, TabStopPosition } = require('docx');
const fs = require('fs');

// Color palette
const COLORS = {
  navy: "1B365D",
  teal: "008080",
  orange: "E67300",
  gold: "D4A84B",
  lightGray: "F5F5F5",
  mediumGray: "E8E8E8",
  darkGray: "333333",
  white: "FFFFFF",
  lightBlue: "E8F4F8",
  lightTeal: "E0F2F1",
  lightOrange: "FFF3E0"
};

// Helper function to create styled paragraphs
function createPara(text, options = {}) {
  const textRuns = [];
  if (typeof text === 'string') {
    textRuns.push(new TextRun({
      text: text,
      bold: options.bold || false,
      italics: options.italics || false,
      color: options.color || COLORS.darkGray,
      size: options.size || 24, // 12pt
      font: "Arial"
    }));
  } else {
    // Array of TextRun configs
    text.forEach(t => {
      textRuns.push(new TextRun({
        text: t.text,
        bold: t.bold || false,
        italics: t.italics || false,
        color: t.color || COLORS.darkGray,
        size: t.size || 24,
        font: "Arial"
      }));
    });
  }
  
  return new Paragraph({
    children: textRuns,
    alignment: options.alignment || AlignmentType.LEFT,
    spacing: { before: options.spaceBefore || 120, after: options.spaceAfter || 120 }
  });
}

// Create callout box (table with colored background)
function createCalloutBox(title, content, type = "info") {
  const bgColors = {
    info: COLORS.lightBlue,
    warning: COLORS.lightOrange,
    tip: COLORS.lightTeal,
    important: COLORS.lightOrange
  };
  const borderColors = {
    info: COLORS.teal,
    warning: COLORS.orange,
    tip: COLORS.teal,
    important: COLORS.orange
  };
  const iconText = {
    info: "ℹ️ ",
    warning: "⚠️ ",
    tip: "💡 ",
    important: "❗ "
  };
  
  const border = { style: BorderStyle.SINGLE, size: 12, color: borderColors[type] };
  
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            borders: { top: border, bottom: border, left: border, right: border },
            width: { size: 9360, type: WidthType.DXA },
            shading: { fill: bgColors[type], type: ShadingType.CLEAR },
            margins: { top: 150, bottom: 150, left: 200, right: 200 },
            children: [
              new Paragraph({
                children: [
                  new TextRun({ text: iconText[type] + title, bold: true, size: 24, color: borderColors[type], font: "Arial" })
                ],
                spacing: { after: 80 }
              }),
              new Paragraph({
                children: [
                  new TextRun({ text: content, size: 22, color: COLORS.darkGray, font: "Arial" })
                ]
              })
            ]
          })
        ]
      })
    ]
  });
}

// Create section divider
function createSectionDivider() {
  const border = { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray };
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            borders: { top: border, bottom: BorderStyle.NONE, left: BorderStyle.NONE, right: BorderStyle.NONE },
            width: { size: 9360, type: WidthType.DXA },
            children: [new Paragraph({ children: [] })]
          })
        ]
      })
    ]
  });
}

// Create checklist item
function createChecklistItem(text, checked = false) {
  return new Paragraph({
    children: [
      new TextRun({ text: checked ? "☑ " : "☐ ", size: 24, font: "Arial" }),
      new TextRun({ text: text, size: 24, font: "Arial" })
    ],
    spacing: { before: 60, after: 60 }
  });
}

// Build document structure
const doc = new Document({
  styles: {
    default: {
      document: {
        run: { font: "Arial", size: 24 }
      }
    },
    paragraphStyles: [
      {
        id: "Heading1",
        name: "Heading 1",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 48, bold: true, color: COLORS.navy, font: "Arial" },
        paragraph: { spacing: { before: 400, after: 200 }, outlineLevel: 0 }
      },
      {
        id: "Heading2",
        name: "Heading 2",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 36, bold: true, color: COLORS.navy, font: "Arial" },
        paragraph: { spacing: { before: 300, after: 150 }, outlineLevel: 1 }
      },
      {
        id: "Heading3",
        name: "Heading 3",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 28, bold: true, color: COLORS.teal, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 2 }
      },
      {
        id: "Title",
        name: "Title",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 72, bold: true, color: COLORS.navy, font: "Arial" },
        paragraph: { alignment: AlignmentType.CENTER, spacing: { before: 0, after: 200 } }
      }
    ]
  },
  numbering: {
    config: [
      {
        reference: "bullets",
        levels: [{
          level: 0,
          format: LevelFormat.BULLET,
          text: "•",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } }
        }]
      },
      {
        reference: "numbers",
        levels: [{
          level: 0,
          format: LevelFormat.DECIMAL,
          text: "%1.",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } }
        }]
      },
      {
        reference: "subBullets",
        levels: [
          {
            level: 0,
            format: LevelFormat.BULLET,
            text: "•",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } }
          },
          {
            level: 1,
            format: LevelFormat.BULLET,
            text: "○",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 1080, hanging: 360 } } }
          }
        ]
      }
    ]
  },
  sections: [
    // =====================
    // TITLE PAGE
    // =====================
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      children: [
        new Paragraph({ children: [], spacing: { before: 2000 } }),
        new Paragraph({
          children: [new TextRun({ text: "THE", size: 36, color: COLORS.teal, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "DIGITAL STRATEGY", size: 80, color: COLORS.navy, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER,
          spacing: { before: 100 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "HANDBOOK", size: 80, color: COLORS.navy, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 200 } }),
        new Paragraph({
          children: [new TextRun({ text: "A Complete Guide to Privacy, Security,", size: 32, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "and Digital Asset Strategy", size: 32, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 2000 } }),
        new Paragraph({
          children: [new TextRun({ text: "VANGUARD ACADEMY", size: 28, color: COLORS.teal, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "Training Sovereign Individuals for the Decentralized Economy", size: 22, color: COLORS.darkGray, font: "Arial" })],
          alignment: AlignmentType.CENTER
        })
      ]
    },
    
    // =====================
    // TABLE OF CONTENTS PAGE
    // =====================
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: "THE DIGITAL STRATEGY HANDBOOK", size: 18, color: COLORS.teal, font: "Arial" })
              ],
              alignment: AlignmentType.RIGHT
            })
          ]
        })
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: "VANGUARD ACADEMY  •  ", size: 18, color: COLORS.navy, font: "Arial" }),
                new TextRun({ text: "Page ", size: 18, font: "Arial" }),
                new TextRun({ children: [PageNumber.CURRENT], size: 18, font: "Arial" })
              ],
              alignment: AlignmentType.CENTER
            })
          ]
        })
      },
      children: [
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "TABLE OF CONTENTS", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        // TOC entries
        createPara([
          { text: "INTRODUCTION", bold: true, color: COLORS.navy },
          { text: " .......................................................................................... ", color: COLORS.mediumGray },
          { text: "4", color: COLORS.darkGray }
        ]),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        
        createPara([
          { text: "PART I: FOUNDATIONS", bold: true, color: COLORS.navy, size: 26 }
        ]),
        createPara([
          { text: "    Chapter 1: The Shift to Sovereignty" },
          { text: " ......................................................... ", color: COLORS.mediumGray },
          { text: "8" }
        ]),
        createPara([
          { text: "    Chapter 2: Understanding the Surveillance Economy" },
          { text: " .......................... ", color: COLORS.mediumGray },
          { text: "15" }
        ]),
        createPara([
          { text: "    Chapter 3: The Economics of Privacy" },
          { text: " .................................................. ", color: COLORS.mediumGray },
          { text: "24" }
        ]),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        
        createPara([
          { text: "PART II: YOUR DIGITAL INFRASTRUCTURE", bold: true, color: COLORS.navy, size: 26 }
        ]),
        createPara([
          { text: "    Chapter 4: Wallet Architecture" },
          { text: " ............................................................. ", color: COLORS.mediumGray },
          { text: "32" }
        ]),
        createPara([
          { text: "    Chapter 5: Security Protocols" },
          { text: " ............................................................... ", color: COLORS.mediumGray },
          { text: "42" }
        ]),
        createPara([
          { text: "    Chapter 6: Recovery Planning" },
          { text: " ................................................................ ", color: COLORS.mediumGray },
          { text: "52" }
        ]),
        createPara([
          { text: "    Chapter 7: Operational Security" },
          { text: " ............................................................ ", color: COLORS.mediumGray },
          { text: "60" }
        ]),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        
        createPara([
          { text: "PART III: EVALUATION FRAMEWORKS", bold: true, color: COLORS.navy, size: 26 }
        ]),
        createPara([
          { text: "    Chapter 8: How to Research Any Token" },
          { text: " .............................................. ", color: COLORS.mediumGray },
          { text: "70" }
        ]),
        createPara([
          { text: "    Chapter 9: Due Diligence Methodology" },
          { text: " ............................................. ", color: COLORS.mediumGray },
          { text: "82" }
        ]),
        createPara([
          { text: "    Chapter 10: Risk Assessment Matrices" },
          { text: " ............................................. ", color: COLORS.mediumGray },
          { text: "94" }
        ]),
        createPara([
          { text: "    Chapter 11: Identifying Scams and Red Flags" },
          { text: " .................................... ", color: COLORS.mediumGray },
          { text: "104" }
        ]),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        
        createPara([
          { text: "PART IV: THE VANGUARD PATH", bold: true, color: COLORS.navy, size: 26 }
        ]),
        createPara([
          { text: "    Chapter 12: Introduction to DAO Participation" },
          { text: " ................................. ", color: COLORS.mediumGray },
          { text: "114" }
        ]),
        createPara([
          { text: "    Chapter 13: How Coordination Protocols Work" },
          { text: " ................................... ", color: COLORS.mediumGray },
          { text: "122" }
        ]),
        createPara([
          { text: "    Chapter 14: The Opportunity Ahead" },
          { text: " ...................................................... ", color: COLORS.mediumGray },
          { text: "130" }
        ]),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        
        createPara([
          { text: "APPENDICES", bold: true, color: COLORS.navy, size: 26 }
        ]),
        createPara([
          { text: "    Appendix A: Wallet Setup Checklist" },
          { text: " .................................................... ", color: COLORS.mediumGray },
          { text: "138" }
        ]),
        createPara([
          { text: "    Appendix B: Security Audit Template" },
          { text: " .................................................. ", color: COLORS.mediumGray },
          { text: "142" }
        ]),
        createPara([
          { text: "    Appendix C: Token Evaluation Scorecard" },
          { text: " ............................................. ", color: COLORS.mediumGray },
          { text: "146" }
        ]),
        createPara([
          { text: "    Appendix D: Glossary of Terms" },
          { text: " ........................................................... ", color: COLORS.mediumGray },
          { text: "150" }
        ])
      ]
    },
    
    // =====================
    // INTRODUCTION
    // =====================
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [new TextRun({ text: "INTRODUCTION", size: 18, color: COLORS.teal, font: "Arial" })],
              alignment: AlignmentType.RIGHT
            })
          ]
        })
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: "VANGUARD ACADEMY  •  ", size: 18, color: COLORS.navy, font: "Arial" }),
                new TextRun({ text: "Page ", size: 18, font: "Arial" }),
                new TextRun({ children: [PageNumber.CURRENT], size: 18, font: "Arial" })
              ],
              alignment: AlignmentType.CENTER
            })
          ]
        })
      },
      children: [
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "INTRODUCTION", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "You are not in control of your financial life.", bold: true, size: 28, color: COLORS.navy }
        ], { spaceBefore: 200 }),
        
        createPara("This is not an accusation. It's a statement of fact for the vast majority of people in the modern economy. Your bank can freeze your account. Your government can seize your assets. Payment processors can refuse your transactions. Data brokers know your spending habits better than you do."),
        
        createPara("The infrastructure of modern finance was not built for your benefit. It was built for the benefit of the institutions that control it. You are a user of that system—tolerated when profitable, excluded when inconvenient."),
        
        createPara("This handbook is about changing that."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createCalloutBox(
          "What This Handbook Is NOT",
          "This is not financial advice. This is not a guide to tax evasion. This is not a manual for illegal activity. This is education about technologies and strategies that allow individuals to take greater control of their digital and financial lives—within the bounds of applicable law.",
          "warning"
        ),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "The Sovereign Individual", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("The concept of the 'sovereign individual' has been discussed by philosophers and futurists for decades. The core idea is simple: technology enables individuals to operate with capabilities once reserved for institutions and governments."),
        
        createPara("A medieval peasant could not send money across borders. A 20th-century citizen could not publish to a global audience. Today, both are trivial. Blockchain technology extends this trend to finance itself."),
        
        createPara("With the right knowledge and tools, you can:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Hold assets that no one can seize without your cooperation", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Transact with anyone in the world without intermediary approval", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Maintain privacy over your financial activities when you choose", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Participate in economic systems that reward contribution over credentials", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Build wealth through skills rather than geographic accident", size: 24, font: "Arial" })]
        }),
        
        createPara("This handbook teaches you how."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "Who This Handbook Is For", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("This handbook is designed for individuals who:"),
        
        new Paragraph({
          numbering: { reference: "numbers", level: 0 },
          children: [new TextRun({ text: "Recognize that the traditional financial system doesn't serve their interests", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "numbers", level: 0 },
          children: [new TextRun({ text: "Want to understand how blockchain technology enables personal sovereignty", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "numbers", level: 0 },
          children: [new TextRun({ text: "Are willing to invest time in learning new skills and concepts", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "numbers", level: 0 },
          children: [new TextRun({ text: "Seek practical frameworks rather than speculation or hype", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "numbers", level: 0 },
          children: [new TextRun({ text: "Are interested in participating in the emerging decentralized economy", size: 24, font: "Arial" })]
        }),
        
        createPara("You don't need prior experience with cryptocurrency. You don't need a technical background. You don't need significant capital. You need curiosity, patience, and a willingness to take responsibility for your own financial infrastructure."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "How to Use This Handbook", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("This handbook is structured as a progressive journey:"),
        
        createCalloutBox(
          "Part I: Foundations",
          "Establishes the philosophical and practical case for digital sovereignty. Read this first to understand why the specific techniques in later sections matter.",
          "info"
        ),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        createCalloutBox(
          "Part II: Digital Infrastructure",
          "Teaches you how to set up and secure the tools you'll need. This is hands-on—you should complete the exercises before moving on.",
          "info"
        ),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        createCalloutBox(
          "Part III: Evaluation Frameworks",
          "Provides professional-grade methods for analyzing opportunities and risks. These are the same frameworks used by institutional investors.",
          "info"
        ),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        createCalloutBox(
          "Part IV: The Vanguard Path",
          "Introduces the opportunity to apply your knowledge in real economic activity through DAO participation.",
          "info"
        ),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "The appendices contain practical tools: checklists, templates, and reference materials you'll use repeatedly. Consider printing them for quick access.", italics: true }
        ]),
        
        new Paragraph({ children: [], spacing: { before: 300 } }),
        
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "\"The goal is not to hide from the world. The goal is to engage with it on your own terms.\"", italics: true, size: 26, color: COLORS.teal }
        ], { alignment: AlignmentType.CENTER }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara("Let's begin.", { alignment: AlignmentType.CENTER })
      ]
    },
    
    // =====================
    // PART I - FOUNDATIONS
    // =====================
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [new TextRun({ text: "PART I: FOUNDATIONS", size: 18, color: COLORS.teal, font: "Arial" })],
              alignment: AlignmentType.RIGHT
            })
          ]
        })
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: "VANGUARD ACADEMY  •  ", size: 18, color: COLORS.navy, font: "Arial" }),
                new TextRun({ text: "Page ", size: 18, font: "Arial" }),
                new TextRun({ children: [PageNumber.CURRENT], size: 18, font: "Arial" })
              ],
              alignment: AlignmentType.CENTER
            })
          ]
        })
      },
      children: [
        // Part I Title Page
        new Paragraph({ children: [], spacing: { before: 3000 } }),
        new Paragraph({
          children: [new TextRun({ text: "PART I", size: 36, color: COLORS.teal, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "FOUNDATIONS", size: 72, color: COLORS.navy, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER,
          spacing: { before: 100, after: 400 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 400 } }),
        new Paragraph({
          children: [new TextRun({ text: "Understanding why sovereignty matters", size: 28, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "before learning how to achieve it", size: 28, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        
        new Paragraph({
          children: [new TextRun({ text: "", font: "Arial" })],
          pageBreakBefore: true
        }),
        
        // Chapter 1
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "CHAPTER 1", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "The Shift to Sovereignty", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "For most of human history, finance was personal.", bold: true }
        ]),
        
        createPara("You held your wealth—gold coins, livestock, land. You transacted directly with counterparties. If you saved, you buried coins in your yard or hid them in your mattress. Primitive, perhaps, but sovereign."),
        
        createPara("The modern financial system changed this. Banks promised safety and convenience in exchange for custody of your assets. Over time, this trade became mandatory. Try operating in the modern economy without a bank account—it's nearly impossible."),
        
        createPara("What we gained in convenience, we lost in control."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "The Custody Tradeoff", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("When you deposit money in a bank, you no longer own that money. Legally, you own a claim against the bank—an IOU. The bank owns the money and can do (almost) whatever it wants with it."),
        
        createPara("This distinction matters because:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Your access can be revoked at the bank's discretion", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Your transactions can be blocked, delayed, or reversed", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Your activity is surveilled and shared with third parties", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "If the bank fails, your claim may not be fully honored", size: 24, font: "Arial" })]
        }),
        
        createPara("This isn't hypothetical. Account freezes happen every day. Sometimes for good reasons (fraud prevention), sometimes for bureaucratic errors, sometimes for political purposes."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createCalloutBox(
          "The Greek Bank Crisis (2015)",
          "When Greece faced sovereign debt default, the government imposed capital controls overnight. Citizens could withdraw only €60 per day from ATMs. Bank accounts were frozen. Businesses couldn't pay suppliers. The economy ground to a halt—not because there was no money, but because access to money was controlled by institutions that prioritized their survival over individual needs.",
          "important"
        ),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "The Self-Custody Alternative", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("Blockchain technology enables a return to self-custody—but with modern capabilities."),
        
        createPara([
          { text: "Self-custody means: ", bold: true },
          { text: "You hold the cryptographic keys that control your assets. No intermediary can freeze, seize, or block your access. Your assets exist on a decentralized network that no single entity controls." }
        ]),
        
        createPara("This isn't a step backward to burying gold. It's a step forward to a system where:"),
        
        // Comparison table
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [4680, 4680],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 100, bottom: 100, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Traditional Finance", bold: true, color: COLORS.white, size: 24, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.teal, type: ShadingType.CLEAR },
                  margins: { top: 100, bottom: 100, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Self-Custody", bold: true, color: COLORS.white, size: 24, font: "Arial" })], alignment: AlignmentType.CENTER })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Bank holds your money", size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "You hold your keys", size: 22, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Access can be revoked", size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Access is unconditional", size: 22, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "All activity is tracked", size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Privacy options exist", size: 22, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Geographic restrictions", size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Global by default", size: 22, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Business hours only", size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 150, right: 150 },
                  children: [new Paragraph({ children: [new TextRun({ text: "24/7/365 availability", size: 22, font: "Arial" })] })]
                })
              ]
            })
          ]
        }),
        
        new Paragraph({ children: [], spacing: { before: 300 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "The Responsibility Trade", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("Self-custody isn't free. You trade convenience and safety nets for control and responsibility."),
        
        createCalloutBox(
          "The Core Tradeoff",
          "If you lose your keys, no one can recover your assets. There's no 'forgot password' link. There's no customer support to call. Self-sovereignty means self-responsibility.",
          "warning"
        ),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara("This handbook will teach you how to manage that responsibility safely. You'll learn:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "How to structure your wallet architecture for security and convenience", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "How to create recovery systems that protect against loss without creating vulnerability", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "How to evaluate which assets to hold in self-custody vs. custodial solutions", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "How to maintain operational security in your daily activities", size: 24, font: "Arial" })]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "Chapter Summary", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        // Summary box
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [9360],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, bottom: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, left: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, right: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal } },
                  width: { size: 9360, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 150, bottom: 150, left: 200, right: 200 },
                  children: [
                    new Paragraph({
                      children: [new TextRun({ text: "KEY TAKEAWAYS", bold: true, size: 26, color: COLORS.teal, font: "Arial" })],
                      spacing: { after: 150 }
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Traditional finance requires surrendering custody of your assets to intermediaries.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "This custody relationship means your access is always conditional and your activity is always surveilled.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Blockchain technology enables self-custody: you hold keys, you control assets.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Self-custody trades convenience for control. This trade is worthwhile but requires education.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "The rest of this handbook teaches you how to exercise that control safely.", size: 22, font: "Arial" })]
                    })
                  ]
                })
              ]
            })
          ]
        }),
        
        // Page break before Chapter 2
        new Paragraph({
          children: [new TextRun({ text: "", font: "Arial" })],
          pageBreakBefore: true
        }),
        
        // Chapter 2
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "CHAPTER 2", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "Understanding the Surveillance Economy", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "Your financial data is more valuable than you realize.", bold: true }
        ]),
        
        createPara("Every transaction you make tells a story. Where you shop reveals where you live and work. What you buy reveals your interests, habits, and vulnerabilities. When you buy reveals your routines. How much you spend reveals your income and financial status."),
        
        createPara("This data is collected, analyzed, packaged, and sold. You are not the customer of this industry—you are the product."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "Who Collects Your Financial Data", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Your Bank", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createPara("Banks collect everything: every deposit, every withdrawal, every transfer, every bill payment. They know your income, your rent, your subscriptions. They analyze this data to:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Determine your creditworthiness", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Market additional products to you", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Share with government agencies upon request", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Sell (in anonymized form) to data aggregators", size: 24, font: "Arial" })]
        }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Payment Networks", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createPara("Visa, Mastercard, and other payment networks see every card transaction. They know the merchant, the amount, the time, and the location. They sell this data to:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Advertisers (aggregated consumer spending trends)", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Hedge funds (real-time economic indicators)", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Merchants (customer insights)", size: 24, font: "Arial" })]
        }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Merchants Themselves", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createPara("Every store with a loyalty program tracks your purchases. Amazon knows what you browse, what you buy, and what you consider buying. These companies build detailed profiles used for:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Personalized pricing (sometimes charging you more based on your profile)", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Targeted advertising", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Inventory and marketing decisions", size: 24, font: "Arial" })]
        }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Data Brokers", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createPara("Companies like Experian, Equifax, and countless lesser-known firms aggregate data from multiple sources. They combine your financial data with:"),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Public records (property ownership, court filings)", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Social media activity", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Location data from your phone", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Browsing history", size: 24, font: "Arial" })]
        }),
        
        createPara("The result is a comprehensive profile that knows you better than you know yourself."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "How This Data Is Used Against You", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createCalloutBox(
          "Price Discrimination",
          "Insurance companies use financial data to adjust premiums. Landlords use it to screen tenants. Employers use it to make hiring decisions. The 'price' you pay for goods, services, housing, and employment is increasingly personalized—and not in your favor.",
          "important"
        ),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "This isn't paranoia. It's the business model of the modern economy. Your data is valuable because it enables prediction and manipulation of your behavior.", italics: true }
        ]),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "The Blockchain Privacy Spectrum", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        createPara("Contrary to popular belief, most blockchain transactions are not private. Bitcoin, Ethereum, and most major networks are pseudonymous, not anonymous. Every transaction is publicly visible; the question is whether your real identity can be linked to your blockchain addresses."),
        
        createPara("Privacy exists on a spectrum:"),
        
        // Privacy spectrum table
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [2340, 2340, 2340, 2340],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Level", bold: true, color: COLORS.white, size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Description", bold: true, color: COLORS.white, size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Example", bold: true, color: COLORS.white, size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Tradeoff", bold: true, color: COLORS.white, size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Fully Transparent", bold: true, size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "KYC exchange, public address", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Coinbase + ENS", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Easy, but no privacy", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Pseudonymous", bold: true, size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Self-custody, basic hygiene", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Fresh wallet, no ENS", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Linkable with effort", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Enhanced Privacy", bold: true, size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Privacy tools + practices", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Mixers, bridges", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "More complex", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Native Privacy", bold: true, size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Privacy-by-design chains", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Monero, Zcash", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 2340, type: WidthType.DXA },
                  shading: { fill: COLORS.lightTeal, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 100, right: 100 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Limited DeFi access", size: 20, font: "Arial" })] })]
                })
              ]
            })
          ]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara("Part II of this handbook will teach you how to operate at your chosen level of the privacy spectrum, with practical techniques for each level."),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_2,
          children: [new TextRun({ text: "Chapter Summary", bold: true, size: 36, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [9360],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, bottom: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, left: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal }, right: { style: BorderStyle.SINGLE, size: 8, color: COLORS.teal } },
                  width: { size: 9360, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 150, bottom: 150, left: 200, right: 200 },
                  children: [
                    new Paragraph({
                      children: [new TextRun({ text: "KEY TAKEAWAYS", bold: true, size: 26, color: COLORS.teal, font: "Arial" })],
                      spacing: { after: 150 }
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Your financial data is collected by banks, payment networks, merchants, and data brokers.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "This data is used for marketing, pricing, employment, and insurance decisions.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Most blockchain transactions are pseudonymous, not anonymous.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "Privacy exists on a spectrum from fully transparent to native privacy.", size: 22, font: "Arial" })]
                    }),
                    new Paragraph({
                      numbering: { reference: "numbers", level: 0 },
                      children: [new TextRun({ text: "You can choose your level of privacy based on your needs and risk tolerance.", size: 22, font: "Arial" })]
                    })
                  ]
                })
              ]
            })
          ]
        })
      ]
    },
    
    // =====================
    // APPENDICES SECTION
    // =====================
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [new TextRun({ text: "APPENDICES", size: 18, color: COLORS.teal, font: "Arial" })],
              alignment: AlignmentType.RIGHT
            })
          ]
        })
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: "VANGUARD ACADEMY  •  ", size: 18, color: COLORS.navy, font: "Arial" }),
                new TextRun({ text: "Page ", size: 18, font: "Arial" }),
                new TextRun({ children: [PageNumber.CURRENT], size: 18, font: "Arial" })
              ],
              alignment: AlignmentType.CENTER
            })
          ]
        })
      },
      children: [
        // Appendices Part Page
        new Paragraph({ children: [], spacing: { before: 3000 } }),
        new Paragraph({
          children: [new TextRun({ text: "APPENDICES", size: 72, color: COLORS.navy, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 400 } }),
        new Paragraph({
          children: [new TextRun({ text: "Practical tools, checklists, and templates", size: 28, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "for immediate implementation", size: 28, color: COLORS.darkGray, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        
        new Paragraph({
          children: [new TextRun({ text: "", font: "Arial" })],
          pageBreakBefore: true
        }),
        
        // Appendix A
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "APPENDIX A", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "Wallet Setup Checklist", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "Use this checklist when setting up a new self-custody wallet. Do not skip steps.", bold: true, color: COLORS.navy }
        ]),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Pre-Setup Security", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createChecklistItem("Device is clean (no malware, updated OS)"),
        createChecklistItem("On secure, private network (not public WiFi)"),
        createChecklistItem("Screen is not visible to others or cameras"),
        createChecklistItem("Recording devices disabled or removed from area"),
        createChecklistItem("Pen and paper ready (NOT digital note-taking)"),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Wallet Creation", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createChecklistItem("Downloaded wallet from official source (verified URL)"),
        createChecklistItem("Generated new wallet (never import an existing seed for primary wallet)"),
        createChecklistItem("Written seed phrase on paper (all words, correct order)"),
        createChecklistItem("Verified seed phrase by reading back"),
        createChecklistItem("Second copy of seed phrase created"),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Seed Phrase Security", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createChecklistItem("Seed phrase NEVER typed into any device"),
        createChecklistItem("Seed phrase NEVER photographed"),
        createChecklistItem("Seed phrase NEVER stored in cloud/email/notes app"),
        createChecklistItem("Seed phrase copies stored in separate physical locations"),
        createChecklistItem("Seed phrase storage is fireproof/waterproof if possible"),
        createChecklistItem("Trusted person knows recovery procedure (NOT the seed itself)"),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Verification", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        createChecklistItem("Sent small test transaction to wallet"),
        createChecklistItem("Deleted wallet from device"),
        createChecklistItem("Restored wallet from seed phrase"),
        createChecklistItem("Confirmed test transaction balance appears"),
        createChecklistItem("Wallet is now ready for use"),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createCalloutBox(
          "Critical Warning",
          "Never store significant value in a wallet until you have completed the deletion/restoration test. Many people have lost funds because their backup was incorrect and they only discovered this when trying to recover.",
          "warning"
        ),
        
        // Page break for Appendix B
        new Paragraph({
          children: [new TextRun({ text: "", font: "Arial" })],
          pageBreakBefore: true
        }),
        
        // Appendix B
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "APPENDIX B", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        new Paragraph({
          heading: HeadingLevel.HEADING_1,
          children: [new TextRun({ text: "Token Evaluation Scorecard", bold: true, size: 48, color: COLORS.navy, font: "Arial" })]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        createPara([
          { text: "Score each category 1-5 (5 = excellent). Total score helps assess relative risk.", bold: true, color: COLORS.navy }
        ]),
        
        new Paragraph({ children: [], spacing: { before: 150 } }),
        
        // Scorecard table
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [4680, 1560, 3120],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Category", bold: true, color: COLORS.white, size: 22, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 1560, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Score", bold: true, color: COLORS.white, size: 22, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.navy } },
                  width: { size: 3120, type: WidthType.DXA },
                  shading: { fill: COLORS.navy, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Notes", bold: true, color: COLORS.white, size: 22, font: "Arial" })] })]
                })
              ]
            }),
            // Team section header
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 9360, type: WidthType.DXA },
                  columnSpan: 3,
                  shading: { fill: COLORS.lightBlue, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "TEAM & CREDIBILITY", bold: true, size: 22, color: COLORS.teal, font: "Arial" })] })]
                })
              ]
            }),
            // Team rows
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Team experience & track record", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Transparency & communication", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            // Tokenomics section header
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 9360, type: WidthType.DXA },
                  columnSpan: 3,
                  shading: { fill: COLORS.lightBlue, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "TOKENOMICS", bold: true, size: 22, color: COLORS.teal, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Distribution fairness", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Vesting schedule appropriateness", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Value accrual mechanism clarity", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            // Technical section
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 9360, type: WidthType.DXA },
                  columnSpan: 3,
                  shading: { fill: COLORS.lightBlue, type: ShadingType.CLEAR },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "TECHNICAL", bold: true, size: 22, color: COLORS.teal, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Audit quality & recency", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 4680, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "Code quality & documentation", size: 20, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 1560, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/5", size: 20, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray }, right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.mediumGray } },
                  width: { size: 3120, type: WidthType.DXA },
                  margins: { top: 60, bottom: 60, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            }),
            // Total row
            new TableRow({
              children: [
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy } },
                  width: { size: 4680, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "TOTAL SCORE", bold: true, size: 24, color: COLORS.navy, font: "Arial" })] })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy } },
                  width: { size: 1560, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "___/35", bold: true, size: 24, font: "Arial" })], alignment: AlignmentType.CENTER })]
                }),
                new TableCell({
                  borders: { top: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, bottom: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, left: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy }, right: { style: BorderStyle.SINGLE, size: 2, color: COLORS.navy } },
                  width: { size: 3120, type: WidthType.DXA },
                  shading: { fill: COLORS.lightGray, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [new Paragraph({ children: [new TextRun({ text: "", size: 20, font: "Arial" })] })]
                })
              ]
            })
          ]
        }),
        
        new Paragraph({ children: [], spacing: { before: 200 } }),
        
        new Paragraph({
          heading: HeadingLevel.HEADING_3,
          children: [new TextRun({ text: "Score Interpretation", bold: true, size: 28, color: COLORS.teal, font: "Arial" })]
        }),
        
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "28-35: Strong candidate for further research", size: 24, font: "Arial", bold: true })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "21-27: Proceed with caution, identify weak areas", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "14-20: Significant concerns, require resolution before proceeding", size: 24, font: "Arial" })]
        }),
        new Paragraph({
          numbering: { reference: "bullets", level: 0 },
          children: [new TextRun({ text: "Below 14: Avoid or require exceptional circumstances", size: 24, font: "Arial", color: COLORS.orange })]
        }),
        
        // Final page
        new Paragraph({
          children: [new TextRun({ text: "", font: "Arial" })],
          pageBreakBefore: true
        }),
        
        // Closing page
        new Paragraph({ children: [], spacing: { before: 3000 } }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 400 } }),
        new Paragraph({
          children: [new TextRun({ text: "\"The goal is not to hide from the world.", size: 32, color: COLORS.navy, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "The goal is to engage with it on your own terms.\"", size: 32, color: COLORS.navy, font: "Arial", italics: true })],
          alignment: AlignmentType.CENTER,
          spacing: { after: 400 }
        }),
        new Paragraph({
          children: [new TextRun({ text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", size: 24, color: COLORS.gold })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 600 } }),
        new Paragraph({
          children: [new TextRun({ text: "CONTINUE YOUR JOURNEY", size: 28, color: COLORS.teal, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 200 } }),
        new Paragraph({
          children: [new TextRun({ text: "This handbook is your first step. The skills you develop here", size: 24, font: "Arial" })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "prepare you for real participation in the decentralized economy.", size: 24, font: "Arial" })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 300 } }),
        new Paragraph({
          children: [new TextRun({ text: "When you're ready to go deeper:", size: 24, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 100 } }),
        new Paragraph({
          children: [new TextRun({ text: "vanguardacademy.io", size: 28, color: COLORS.teal, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({ children: [], spacing: { before: 600 } }),
        new Paragraph({
          children: [new TextRun({ text: "VANGUARD ACADEMY", size: 22, color: COLORS.navy, font: "Arial", bold: true })],
          alignment: AlignmentType.CENTER
        }),
        new Paragraph({
          children: [new TextRun({ text: "Training Sovereign Individuals for the Decentralized Economy", size: 18, color: COLORS.darkGray, font: "Arial" })],
          alignment: AlignmentType.CENTER
        })
      ]
    }
  ]
});

// Generate the document
Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync('/home/claude/digital_strategy_handbook.docx', buffer);
  console.log('Document created successfully!');
});
