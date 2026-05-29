// --- SLIDE NAVIGATION LOGIC ---
const slides = document.querySelectorAll('.slide');
const indicatorContainer = document.getElementById('slide-indicators');
const currentIndexSpan = document.getElementById('current-index');
const totalCountSpan = document.getElementById('total-count');

let currentSlideIdx = 0;
totalCountSpan.textContent = slides.length;

// Setup indicators
slides.forEach((_, idx) => {
  const ind = document.createElement('div');
  ind.classList.add('indicator');
  if (idx === 0) ind.classList.add('active');
  ind.addEventListener('click', () => goToSlide(idx));
  indicatorContainer.appendChild(ind);
});

const indicators = document.querySelectorAll('.indicator');

function goToSlide(idx) {
  if (idx < 0 || idx >= slides.length) return;
  
  slides[currentSlideIdx].classList.remove('active');
  indicators[currentSlideIdx].classList.remove('active');
  
  currentSlideIdx = idx;
  
  slides[currentSlideIdx].classList.add('active');
  indicators[currentSlideIdx].classList.add('active');
  
  currentIndexSpan.textContent = currentSlideIdx + 1;
}

function nextSlide() {
  if (currentSlideIdx < slides.length - 1) {
    goToSlide(currentSlideIdx + 1);
  }
}

function prevSlide() {
  if (currentSlideIdx > 0) {
    goToSlide(currentSlideIdx - 1);
  }
}

// Keybind listeners
window.addEventListener('keydown', (e) => {
  if (e.key === 'ArrowRight' || e.key === ' ') {
    e.preventDefault();
    nextSlide();
  } else if (e.key === 'ArrowLeft') {
    e.preventDefault();
    prevSlide();
  }
});


// --- INTERACTIVE DEMO 1: IMPLICIT ANIMATION ---
let implicitState = false;
function toggleImplicitDemo() {
  const box = document.getElementById('implicit-box');
  implicitState = !implicitState;
  
  if (implicitState) {
    box.style.transform = 'scale(1.25) translateX(200px)';
    box.style.backgroundColor = '#be4bdb';
    box.style.borderRadius = '50%';
    box.style.boxShadow = '0 0 25px rgba(190, 75, 219, 0.6)';
  } else {
    box.style.transform = 'scale(1) translateX(0)';
    box.style.backgroundColor = '#3498db';
    box.style.borderRadius = '8px';
    box.style.boxShadow = '0 0 15px rgba(52, 152, 219, 0.4)';
  }
}


// --- INTERACTIVE DEMO 2: EXPLICIT ANIMATION ---
let explicitAngle = 0;
let explicitInterval = null;
let explicitDirection = 1; // 1 = forward, -1 = backward

function startExplicit() {
  if (explicitInterval) clearInterval(explicitInterval);
  
  explicitInterval = setInterval(() => {
    explicitAngle += 2.5 * explicitDirection;
    document.getElementById('explicit-box').style.transform = `rotate(${explicitAngle}deg)`;
  }, 16);
}

function pauseExplicit() {
  if (explicitInterval) {
    clearInterval(explicitInterval);
    explicitInterval = null;
  }
}

function reverseExplicit() {
  explicitDirection *= -1;
  startExplicit();
}


// --- INTERACTIVE DEMO 3: THREAD STRESS SIMULATOR ---
let simTimer = null;
let spinnerAngle = 0;
let lastFrameTime = performance.now();
let fpsArray = [];
let simRunning = false;

// Spinner animate tick
function tickSpinner() {
  const spinner = document.getElementById('sim-spinner');
  
  // Update rotation angle
  spinnerAngle = (spinnerAngle + 6) % 360;
  spinner.style.transform = `rotate(${spinnerAngle}deg)`;
  
  // Calculate instant FPS
  const now = performance.now();
  const delta = now - lastFrameTime;
  lastFrameTime = now;
  
  const fps = Math.round(1000 / delta);
  if (isFinite(fps) && fps > 0) {
    fpsArray.push(fps);
    if (fpsArray.length > 10) fpsArray.shift();
  }
  
  const averageFps = Math.round(fpsArray.reduce((a, b) => a + b, 0) / fpsArray.length) || 60;
  const fpsSpan = document.getElementById('sim-fps');
  
  if (averageFps < 20) {
    fpsSpan.className = 'fps-lag';
    fpsSpan.textContent = `${averageFps} FPS`;
  } else {
    fpsSpan.className = 'fps-normal';
    fpsSpan.textContent = `${averageFps} FPS`;
  }
  
  if (simRunning) {
    requestAnimationFrame(tickSpinner);
  }
}

// Start visual ticker
function startSpinnerTicker() {
  if (!simRunning) {
    simRunning = true;
    lastFrameTime = performance.now();
    requestAnimationFrame(tickSpinner);
  }
}

startSpinnerTicker();

function runSim(isMainThread) {
  const statusSpan = document.getElementById('sim-status');
  const spinner = document.getElementById('sim-spinner');
  
  if (isMainThread) {
    statusSpan.textContent = 'RUNNING ON MAIN THREAD...';
    statusSpan.style.color = '#ff4757';
    
    // Induce temporary visual freeze to represent Event Loop blocking
    // We set a small timeout first so the text updates before freezing
    setTimeout(() => {
      // Add 'blocked' class to simulate pause on canvas
      spinner.classList.add('blocked');
      
      const start = Date.now();
      // Blocking loop - runs on the event loop directly
      while (Date.now() - start < 1500) {
        // Freeze everything!
      }
      
      // Post stress calculations
      setTimeout(() => {
        spinner.classList.remove('blocked');
        statusSpan.textContent = 'Stress Complete (Jank observed!)';
        statusSpan.style.color = '#3498db';
      }, 50);
    }, 100);
    
  } else {
    statusSpan.textContent = 'SPAWNING WORKER...';
    statusSpan.style.color = '#2ed573';
    
    // Simulate offloading tasks (using chunks or async requestAnimationFrame loops)
    let cycles = 0;
    
    function asyncComputeChunk() {
      if (cycles < 15) {
        cycles++;
        statusSpan.textContent = `Computing block ${cycles}/15 inside WebWorker`;
        
        // Complex mathematical loop but executed asynchronously in microtasks
        // simulating the non-blocking nature of offloaded threads
        const dummy = Array.from({length: 1000000}, (_, i) => Math.sin(i) * Math.cos(i));
        
        setTimeout(asyncComputeChunk, 100);
      } else {
        statusSpan.textContent = 'Worker Task Done (60 FPS preserved!)';
        statusSpan.style.color = '#2ed573';
      }
    }
    
    setTimeout(asyncComputeChunk, 200);
  }
}
