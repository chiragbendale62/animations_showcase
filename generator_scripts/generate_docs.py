import os
import sys
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

import docx
from docx.shared import Inches as DocxInches, Pt as DocxPt, RGBColor as DocxRGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

# --- SETUP OUTPUT DIRECTORY ---
OUTPUT_DIR = "/Users/neosoft/.gemini/antigravity-ide/scratch/flutter_animations_showcase/docs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Colors
NAVY = RGBColor(11, 25, 44)      # #0B192C (Background / Primary)
GOLD = RGBColor(241, 196, 15)    # #F1C40F (Accent Secondary)
WHITE = RGBColor(255, 255, 255)  # #FFFFFF
SILVER = RGBColor(245, 246, 250) # #F5F6FA (Text Light / Containers)
DARK_GRAY = RGBColor(47, 54, 64) # #2F3640
BLUE = RGBColor(52, 152, 219)    # #3498DB (Info Accent)

# --- GENERATE PPTX ---
def generate_presentation():
    prs = Presentation()
    # Set to widescreen (16:9)
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    
    # Helper to add standard dark-themed slide background
    def apply_dark_background(slide):
        background = slide.background
        fill = background.fill
        fill.solid()
        fill.fore_color.rgb = NAVY

    # Helper to create slides with title
    def create_slide(title_text):
        blank_slide_layout = prs.slide_layouts[6] # Blank
        slide = prs.slides.add_slide(blank_slide_layout)
        apply_dark_background(slide)
        
        # Add Header Title
        title_box = slide.shapes.add_textbox(Inches(0.5), Inches(0.4), Inches(12.333), Inches(0.8))
        tf = title_box.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title_text.upper()
        p.font.name = 'Arial'
        p.font.size = Pt(28)
        p.font.bold = True
        p.font.color.rgb = GOLD
        return slide

    # SLIDE 1: Title Slide
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    apply_dark_background(slide)
    
    # Large glowing box or background accents
    title_box = slide.shapes.add_textbox(Inches(1.0), Inches(2.2), Inches(11.333), Inches(3.5))
    tf = title_box.text_frame
    tf.word_wrap = True
    
    p = tf.paragraphs[0]
    p.text = "ADVANCED FLUTTER ANIMATIONS"
    p.font.name = 'Arial'
    p.font.size = Pt(46)
    p.font.bold = True
    p.font.color.rgb = GOLD
    p.alignment = PP_ALIGN.CENTER
    
    p2 = tf.add_paragraph()
    p2.text = "Micro-interactions, Render Optimization, and Multithreaded Isolates"
    p2.font.name = 'Arial'
    p2.font.size = Pt(22)
    p2.font.color.rgb = WHITE
    p2.alignment = PP_ALIGN.CENTER
    p2.space_before = Pt(14)
    
    p3 = tf.add_paragraph()
    p3.text = "A Complete Reference and Performance Lab Guide"
    p3.font.name = 'Arial'
    p3.font.size = Pt(14)
    p3.font.color.rgb = BLUE
    p3.alignment = PP_ALIGN.CENTER
    p3.space_before = Pt(40)

    # SLIDE 2: Core Taxonomy: Implicit vs Explicit
    slide = create_slide("1. Animation Taxonomy in Flutter")
    
    # Left column: Implicit
    left_box = slide.shapes.add_textbox(Inches(0.7), Inches(1.5), Inches(5.6), Inches(5.0))
    ltf = left_box.text_frame
    ltf.word_wrap = True
    
    lp1 = ltf.paragraphs[0]
    lp1.text = "Implicit Animations"
    lp1.font.bold = True
    lp1.font.size = Pt(20)
    lp1.font.color.rgb = GOLD
    
    bullets_left = [
        "What: Framework-managed animations using state changes.",
        "How: Simply set a property (e.g. width) and trigger setState().",
        "Common Widgets: AnimatedContainer, AnimatedOpacity, AnimatedPadding, AnimatedAlign, TweenAnimationBuilder.",
        "Advantages: Minimal boilerplate, automatically handles reverse/interruption.",
        "Best Use Case: One-off, visual decorations, and hover transitions."
    ]
    for b in bullets_left:
        lp = ltf.add_paragraph()
        lp.text = "• " + b
        lp.font.size = Pt(15)
        lp.font.color.rgb = SILVER
        lp.space_before = Pt(10)

    # Right column: Explicit
    right_box = slide.shapes.add_textbox(Inches(6.9), Inches(1.5), Inches(5.6), Inches(5.0))
    rtf = right_box.text_frame
    rtf.word_wrap = True
    
    rp1 = rtf.paragraphs[0]
    rp1.text = "Explicit Animations"
    rp1.font.bold = True
    rp1.font.size = Pt(20)
    rp1.font.color.rgb = BLUE
    
    bullets_right = [
        "What: Developer-managed animations using timers and tickers.",
        "How: Instantiate AnimationController, Animation, and TickerProvider.",
        "Common Widgets: ScaleTransition, RotationTransition, PositionedTransition, AnimatedBuilder.",
        "Advantages: Imperative control (play, pause, reverse, loop, stagger).",
        "Best Use Case: Looping loading indicators, gestures, staggered entry lists, complex game scenes."
    ]
    for b in bullets_right:
        rp = rtf.add_paragraph()
        rp.text = "• " + b
        rp.font.size = Pt(15)
        rp.font.color.rgb = SILVER
        rp.space_before = Pt(10)

    # SLIDE 3: The Flutter Render Pipeline
    slide = create_slide("2. The Rendering & Animation Pipeline")
    
    # 4 Steps visual layout
    step_width = Inches(2.8)
    step_height = Inches(4.5)
    top_pos = Inches(1.8)
    
    steps = [
        {"title": "1. ANIMATE", "desc": "Ticker triggers every frame (~16ms for 60Hz). AnimationController recalculates normalized values (0.0 to 1.0) along selected Curves."},
        {"title": "2. BUILD", "desc": "Flutter marks dirty elements. AnimatedBuilder rebuilds widgets with the newly interpolated values. (Optimizations here prevent redundant builds)."},
        {"title": "3. LAYOUT", "desc": "Widget sizes and position coordinates are recalculated from top to bottom (Constraints go down, sizes go up)."},
        {"title": "4. PAINT", "desc": "Canvas records drawing commands. Using RepaintBoundaries isolates animated widgets, preventing full-screen redraw overhead."}
    ]
    
    for i, step in enumerate(steps):
        left_pos = Inches(0.5 + i * 3.1)
        # Background box
        shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left_pos, top_pos, step_width, step_height)
        shape.fill.solid()
        shape.fill.fore_color.rgb = DARK_GRAY
        shape.line.color.rgb = BLUE
        shape.line.width = Pt(1.5)
        
        stf = shape.text_frame
        stf.word_wrap = True
        
        sp1 = stf.paragraphs[0]
        sp1.text = step["title"]
        sp1.font.bold = True
        sp1.font.size = Pt(18)
        sp1.font.color.rgb = GOLD
        sp1.alignment = PP_ALIGN.CENTER
        
        sp2 = stf.add_paragraph()
        sp2.text = step["desc"]
        sp2.font.size = Pt(14)
        sp2.font.color.rgb = WHITE
        sp2.space_before = Pt(14)

    # SLIDE 4: Performance Pitfalls & Optimization
    slide = create_slide("3. Performance Pitfalls & Code Optimization")
    
    left_box = slide.shapes.add_textbox(Inches(0.5), Inches(1.5), Inches(5.8), Inches(5.0))
    ltf = left_box.text_frame
    ltf.word_wrap = True
    
    lp = ltf.paragraphs[0]
    lp.text = "Common Pitfalls (Why Apps Lag)"
    lp.font.bold = True
    lp.font.size = Pt(20)
    lp.font.color.rgb = GOLD
    
    pitfalls = [
        "Rebuilding entire subtrees when an animation ticks (e.g. recreating massive static icons/layouts in the AnimatedBuilder body).",
        "Failing to call dispose() on AnimationControllers, creating major memory leaks.",
        "Overusing heavy layout-triggering properties (like animating margin or height rather than applying ScaleTransition or Transform.translate).",
        "Executing intensive CPU operations (JSON parsing, path computations) on the Main UI Thread during active animations."
    ]
    for p in pitfalls:
        lp_p = ltf.add_paragraph()
        lp_p.text = "❌ " + p
        lp_p.font.size = Pt(14)
        lp_p.font.color.rgb = SILVER
        lp_p.space_before = Pt(12)

    right_box = slide.shapes.add_textbox(Inches(6.8), Inches(1.5), Inches(6.0), Inches(5.0))
    rtf = right_box.text_frame
    rtf.word_wrap = True
    
    rp = rtf.paragraphs[0]
    rp.text = "Pro-Optimizations"
    rp.font.bold = True
    rp.font.size = Pt(20)
    rp.font.color.rgb = BLUE
    
    opts = [
        "AnimatedBuilder Caching: Pass the static child to AnimatedBuilder and reference it in the builder parameters to bypass rebuilding the static subtree.",
        "RepaintBoundaries: Wrap heavy custom drawings (like Canvas/CustomPainter) to paint them on a separate texture overlay, avoiding main window repaint.",
        "Use const Widgets: Always mark non-animating descendants as const to let Flutter instantly reuse build references.",
        "Use transform and opacity widgets wisely: Prefer Opacity widgets over custom paint alphas where Flutter can optimize engine layers."
    ]
    for o in opts:
        rp_o = rtf.add_paragraph()
        rp_o.text = "✓ " + o
        rp_o.font.size = Pt(14)
        rp_o.font.color.rgb = SILVER
        rp_o.space_before = Pt(12)

    # SLIDE 5: Multi-threaded Rendering & Isolates
    slide = create_slide("4. The Threading Frontier: Dart Isolates")
    
    left_box = slide.shapes.add_textbox(Inches(0.5), Inches(1.5), Inches(6.0), Inches(5.0))
    ltf = left_box.text_frame
    ltf.word_wrap = True
    
    lp = ltf.paragraphs[0]
    lp.text = "The Single-Threaded Barrier"
    lp.font.bold = True
    lp.font.size = Pt(20)
    lp.font.color.rgb = GOLD
    
    text_l = [
        "Dart executes code in a single 'Isolate' with a single-threaded Event Loop.",
        "The Main Isolate manages: UI gestures, animations, rendering, garbage collection, and microtasks.",
        "If a computational load (e.g. spring-mass calculations, physics engine coordinate generator, large JSON data manipulation) takes >16ms, the Main event loop freezes.",
        "Result: Dropped frames, laggy screen updates, animation freeze (UI jank)."
    ]
    for t in text_l:
        lp_t = ltf.add_paragraph()
        lp_t.text = "• " + t
        lp_t.font.size = Pt(15)
        lp_t.font.color.rgb = SILVER
        lp_t.space_before = Pt(10)

    right_box = slide.shapes.add_textbox(Inches(6.8), Inches(1.5), Inches(6.0), Inches(5.0))
    rtf = right_box.text_frame
    rtf.word_wrap = True
    
    rp = rtf.paragraphs[0]
    rp.text = "Offloading with Background Isolates"
    rp.font.bold = True
    rp.font.size = Pt(20)
    rp.font.color.rgb = BLUE
    
    text_r = [
        "Isolates do not share memory: They are completely isolated, run concurrently, and communicate ONLY by sending messages through ReceivePort and SendPort.",
        "Flutter's compute(): Instantly spawns a background worker isolate, runs a static function, returns the value, and kills the worker. Best for quick jobs.",
        "Isolate.spawn(): Creates a persistent background thread. Perfect for high-intensity loop calculations (e.g., coordinates updates for an ongoing particle swarm simulation).",
        "Keeping UI responsive: Main Isolate remains free solely for drawing and animations, ensuring buttery 60/120 FPS."
    ]
    for t in text_r:
        rp_t = rtf.add_paragraph()
        rp_t.text = "• " + t
        rp_t.font.size = Pt(15)
        rp_t.font.color.rgb = SILVER
        rp_t.space_before = Pt(10)

    # SLIDE 6: Summary Cheatsheet
    slide = create_slide("5. Advanced Animation Cheatsheet")
    
    tb = slide.shapes.add_textbox(Inches(1.0), Inches(1.6), Inches(11.333), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    
    summary_points = [
        ("Implicit Widgets First", "Always default to implicit widgets (AnimatedContainer, etc.) for straightforward UI styling changes. They are fast, clean, and bug-free."),
        ("Explicit for State-Controlled loops", "Use explicit controllers when you need to rewind, repeat, pause, or synchronize multiple animations. Be sure to clean up resources in dispose()."),
        ("AnimatedBuilder optimization", "Always leverage the static 'child' parameter in AnimatedBuilder. Rebuilding large static widgets 60 times a second is the #1 source of mobile animation lag."),
        ("Isolates for dynamic calculations", "If generating physics points, path nodes, or parsing database rows to animate later, execute it inside an Isolate. Main-thread execution destroys rendering rates."),
        ("Repaint boundaries isolate noise", "Use RepaintBoundary around intense animating canvas layouts to tell the Skia/Impeller renderer that this zone changes independently.")
    ]
    
    for i, (title, desc) in enumerate(summary_points):
        p = tf.add_paragraph() if i > 0 else tf.paragraphs[0]
        p.text = f"{i+1}. {title}: "
        p.font.bold = True
        p.font.size = Pt(16)
        p.font.color.rgb = GOLD
        if i > 0:
            p.space_before = Pt(12)
            
        p_desc = p
        run = p_desc.add_run()
        run.text = desc
        run.font.bold = False
        run.font.size = Pt(15)
        run.font.color.rgb = SILVER

    prs.save(os.path.join(OUTPUT_DIR, "flutter_animations_presentation.pptx"))
    print("PowerPoint (.pptx) presentation generated successfully.")

# --- GENERATE DOCX ---
def set_cell_background(cell, fill_hex):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def generate_word_doc():
    doc = docx.Document()
    
    # Configure overall styles
    style = doc.styles['Normal']
    font = style.font
    font.name = 'Calibri'
    font.size = DocxPt(11)
    font.color.rgb = DocxRGBColor(47, 54, 64)
    
    # Document Title
    title = doc.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_run = title.add_run("THE FLUTTER ADVANCED ANIMATIONS AND PERFORMANCE MANUAL")
    title_run.font.name = 'Arial'
    title_run.font.size = DocxPt(24)
    title_run.font.bold = True
    title_run.font.color.rgb = DocxRGBColor(11, 25, 44)
    title.space_after = DocxPt(20)
    
    # Subtitle
    subtitle = doc.add_paragraph()
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sub_run = subtitle.add_run("A Deep Dive into Implicit & Explicit Systems, Rendering Pipeline, Repaint boundaries, and Multithreaded Calculations with Isolates")
    sub_run.font.size = DocxPt(12)
    sub_run.font.italic = True
    sub_run.font.color.rgb = DocxRGBColor(52, 152, 219)
    subtitle.space_after = DocxPt(30)
    
    # Helper to add section headers
    def add_heading_1(text):
        p = doc.add_paragraph()
        p.space_before = DocxPt(18)
        p.space_after = DocxPt(6)
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = DocxPt(16)
        r.font.bold = True
        r.font.color.rgb = DocxRGBColor(11, 25, 44)
        p.paragraph_format.keep_with_next = True
        return p

    def add_heading_2(text):
        p = doc.add_paragraph()
        p.space_before = DocxPt(12)
        p.space_after = DocxPt(4)
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = DocxPt(13)
        r.font.bold = True
        r.font.color.rgb = DocxRGBColor(52, 152, 219)
        p.paragraph_format.keep_with_next = True
        return p

    def add_code_block(code_text):
        p = doc.add_paragraph()
        p.paragraph_format.left_indent = DocxInches(0.4)
        p.paragraph_format.right_indent = DocxInches(0.4)
        p.space_before = DocxPt(6)
        p.space_after = DocxPt(6)
        
        # Add background borders by using a 1x1 table
        tbl = doc.add_table(rows=1, cols=1)
        tbl.autofit = False
        tbl.columns[0].width = DocxInches(5.7)
        cell = tbl.cell(0, 0)
        cell.width = DocxInches(5.7)
        set_cell_background(cell, "F5F6FA")
        
        cp = cell.paragraphs[0]
        cp.paragraph_format.space_before = DocxPt(4)
        cp.paragraph_format.space_after = DocxPt(4)
        r = cp.add_run(code_text)
        r.font.name = 'Courier New'
        r.font.size = DocxPt(9.5)
        r.font.color.rgb = DocxRGBColor(47, 54, 64)

    # --- SECTION 1 ---
    add_heading_1("1. Architectural Taxonomy of Animations")
    p = doc.add_paragraph("Flutter animations are divided into two main categories depending on who manages the lifecycle: Implicit (framework-managed) and Explicit (developer-managed). Understanding this distinction is vital to building lightweight, maintainable codebases.")
    
    add_heading_2("Implicit Animations (Self-Running)")
    doc.add_paragraph("Implicit animations require minimal coding. You configure a target styling value (such as width, opacity, color, padding) on an animating widget. When that target value changes and a rebuild occurs, the widget automatically animates the transition over a specified Duration using a preset Curve. Flutter abstracts the tickers, state machine, interpolation, and controllers underneath.")
    doc.add_paragraph("Key Implicit Widgets include: AnimatedContainer, AnimatedPadding, AnimatedPositioned, AnimatedOpacity, and AnimatedCrossFade. If a specialized implicit widget is missing, developers can deploy TweenAnimationBuilder to animate custom values implicitly.")

    add_code_block(
'''// Example of Custom Implicit Animation
TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0.0, end: 1.0),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOutElastic,
  builder: (BuildContext context, double value, Widget? child) {
    return Transform.scale(
      scale: value,
      child: child,
    );
  },
  child: const Icon(Icons.star, size: 64, color: Colors.amber),
);'''
    )

    add_heading_2("Explicit Animations (Directly Controlled)")
    doc.add_paragraph("Explicit animations require developers to instantiate and manually govern an AnimationController. The controller acts as the timekeeper, allowing the app to trigger, stop, reverse, speed up, or continuously repeat animations in response to user events, timers, or custom logic.")
    doc.add_paragraph("Explicit animations utilize: AnimationController, TickerProvider (usually added via SingleTickerProviderStateMixin or TickerProviderStateMixin), and specialized Transition widgets (ScaleTransition, RotationTransition, SlideTransition) or AnimatedBuilder for bespoke visual combinations.")

    add_code_block(
'''// Example of Setup inside a State class
class SpinningGearState extends State<Gear> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Continues spinning forever
    _animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // CRITICAL: Stop leaks!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child, // Optimization: Static child remains untouched!
        );
      },
      child: const CustomHeavyGearIcon(), 
    );
  }
}'''
    )

    # --- SECTION 2 ---
    add_heading_1("2. The Rendering Lifecycle & Execution Path")
    doc.add_paragraph("To optimize animations, developers must understand how the engine displays changes on screens. Every frame ticks through the following pipelines at regular intervals (typically 60Hz or 120Hz):")
    
    tbl = doc.add_table(rows=5, cols=2)
    tbl.autofit = True
    
    headers = ["Lifecycle Stage", "Technical Action Details"]
    for j, h in enumerate(headers):
        cell = tbl.cell(0, j)
        cell.text = h
        set_cell_background(cell, "0B192C")
        cell.paragraphs[0].runs[0].font.bold = True
        cell.paragraphs[0].runs[0].font.color.rgb = DocxRGBColor(255, 255, 255)
        
    pipeline_data = [
        ("1. Ticker Tick", "The system clock signals a new frame (~16.6ms). Ticker informs AnimationController which updates its normalized percentage value based on the selected Curve."),
        ("2. Animation Rebuild", "The framework marks the AnimatedBuilder/setState widget as dirty. BuildContext schedules a rebuild, interpolating Tweens with the fresh controller value."),
        ("3. Layout Phase", "Widgets are computed sizing-wise. If layout properties (like height/width/padding) are animated, massive widget trees recalculate sizes. Transform/translation animations skip this phase, accelerating performance."),
        ("4. Painting & Raster", "Draw commands record onto canvases. Heavy custom paints or canvases recalculate vectors, convert to bitmaps via Skia/Impeller, and rasterize on GPU layers.")
    ]
    
    for i, (stage, desc) in enumerate(pipeline_data):
        row_idx = i + 1
        c0 = tbl.cell(row_idx, 0)
        c0.text = stage
        c0.paragraphs[0].runs[0].font.bold = True
        set_cell_background(c0, "F5F6FA")
        
        c1 = tbl.cell(row_idx, 1)
        c1.text = desc
        
    doc.add_paragraph("") # Spacing after table

    # --- SECTION 3 ---
    add_heading_1("3. Top 5 Performance Pitfalls & Engine Tuning")
    doc.add_paragraph("Mobile apps frequently suffer from animation 'jank' (dropped frames) due to inefficient rendering instructions. The list below identifies critical pitfalls and their exact mitigation solutions:")
    
    p = doc.add_paragraph()
    p.add_run("1. Rebuilding Large Subtrees: ").bold = True
    p.add_run("When using AnimatedBuilder, programmers often instantiate huge static widgets (like complex vector images or columns) directly inside the builder callback. This causes the widget to rebuild entirely 60 times a second, placing severe load on the garbage collector and CPU.")
    
    p = doc.add_paragraph()
    p.add_run("✓ Optimization: ").bold = True
    p.add_run("Utilize the static 'child' parameter in AnimatedBuilder. Pass the heavy widget once into the constructor, and reference the passed child inside the builder. Flutter references this cached object without rebuilding it.")
    
    p = doc.add_paragraph()
    p.add_run("2. Animating Layout Properties: ").bold = True
    p.add_run("Animating layout-triggering properties (e.g. margin, padding, width, height) forces Flutter to re-evaluate structural constraints of sibling and parent elements along the entire branch of the widget tree.")
    
    p = doc.add_paragraph()
    p.add_run("✓ Optimization: ").bold = True
    p.add_run("Prefer Transform widgets (Transform.scale, Transform.translate, SlideTransition). Transitions computed in the Paint/Raster stage completely bypass the structural Layout calculations, leading to flawless execution.")
    
    p = doc.add_paragraph()
    p.add_run("3. Canvas Repaint Overhead: ").bold = True
    p.add_run("When an active animation paints inside a widget, the entire canvas for the screen redraws by default. Sibling elements that are static are repainted alongside, compounding drawing times.")
    
    p = doc.add_paragraph()
    p.add_run("✓ Optimization: ").bold = True
    p.add_run("Isolate active CustomPainter/Canvas code with a ")
    p.add_run("RepaintBoundary").bold = True
    p.add_run(". This tells the Skia/Impeller renderer to capture the widget in its own independent drawing layer (texture), drawing only that layer during animation updates.")

    p = doc.add_paragraph()
    p.add_run("4. Leaving Controllers Active: ").bold = True
    p.add_run("Failing to dispose of controllers causes continuous tickers to execute in the background even after navigating away, causing serious CPU drain and memory consumption.")
    
    p = doc.add_paragraph()
    p.add_run("✓ Optimization: ").bold = True
    p.add_run("Always release controllers in the parent State class dispose() method.")

    # --- SECTION 4 ---
    add_heading_1("4. The Threading Frontier: Background Dart Isolates")
    doc.add_paragraph("Dart code runs in a single-threaded runtime environment known as an Isolate. Each Isolate operates an independent Event Loop. The Main UI Isolate manages user gestures, screen updates, widget builds, and frame drawings.")
    doc.add_paragraph("If the main thread attempts to execute resource-heavy operations (e.g. spring physics coordinate generation, mathematical swarm math, cryptography calculations, complex data sorting) while an animation is active, the loop gets blocked. If the event block lasts longer than 8ms to 16ms, frames drop, causing visual stuttering.")
    
    add_heading_2("Architecture of Dart Isolates")
    doc.add_paragraph("To keep the UI responsive, heavy operations must be offloaded to a background thread. Dart prevents shared memory between threads to avoid race conditions and synchronization lock overhead. Each Isolate is independent, hence the name 'Isolate'.")
    doc.add_paragraph("Isolates communicate solely via messages sent through ReceivePort and SendPort. Sending messages triggers serialize/deserialize sequences, so they should be managed carefully (passed in batches).")

    add_code_block(
'''// High-Performance Persistent Isolate Setup for Ongoing Computations
import 'dart:isolate';

class PhysicsSwarmWorker {
  Isolate? _isolate;
  SendPort? _commandPort;
  final ReceivePort _resultsPort = ReceivePort();

  Future<void> start(Function(List<double>) onDataReceived) async {
    // 1. Spawn the Background Isolate
    _isolate = await Isolate.spawn(_swarmEntrypoint, _resultsPort.sendPort);

    // 2. Listen to output channel
    _resultsPort.listen((message) {
      if (message is SendPort) {
        _commandPort = message; // Grab background control port
      } else if (message is List<double>) {
        onDataReceived(message); // Forward results to UI thread
      }
    });
  }

  // 3. Background entry point must be a static or top-level function
  static void _swarmEntrypoint(SendPort mainSendPort) {
    final ReceivePort backgroundReceivePort = ReceivePort();
    mainSendPort.send(backgroundReceivePort.sendPort); // Send control port to UI

    backgroundReceivePort.listen((msg) {
      if (msg == 'compute_next_swarm_positions') {
        // Run complex Lorenz Attractor or Spring Swarm equations here...
        List<double> coordinates = _calculateEquations(); 
        mainSendPort.send(coordinates);
      }
    });
  }
  
  static List<double> _calculateEquations() {
    // Math logic running entirely on secondary CPU thread
    return List.generate(1000, (i) => i * 1.5); 
  }

  void requestUpdate() {
    _commandPort?.send('compute_next_swarm_positions');
  }

  void stop() {
    _isolate?.kill();
    _resultsPort.close();
  }
}'''
    )

    doc.add_paragraph("Implementing this approach ensures that the Main UI Isolate remains entirely unburdened. The visual animation ticker keeps firing on schedule, maintaining a flawless, fluid rendering rate.")

    doc.save(os.path.join(OUTPUT_DIR, "flutter_animations_guide.docx"))
    print("Word (.docx) document guide generated successfully.")

# --- MAIN EXECUTION ---
if __name__ == "__main__":
    generate_presentation()
    generate_word_doc()
    print("All documents generated successfully inside docs/ folder.")
