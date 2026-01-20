class OnboardingSvgs {
  // SVG 1: Digital Shelf (RTl/Modern Card Stack)
  static const String digitalShelf = '''
<svg width="300" height="300" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="meshGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1E3A8A" />
      <stop offset="100%" stop-color="#3B82F6" />
    </linearGradient>
    <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
      <feDropShadow dx="0" dy="10" stdDeviation="10" flood-opacity="0.15" />
    </filter>
  </defs>

  <!-- Stack Layout approximating the HTML flexbox/absolute positioning -->
  <!-- Card 1 (Back Left) -->
  <rect x="60" y="100" width="40" height="140" rx="8" fill="#F8FAFC" stroke="#E2E8F0" />
  
  <!-- Card 2 (Back Right) -->
  <rect x="200" y="110" width="40" height="130" rx="8" fill="#F8FAFC" stroke="#E2E8F0" />

  <!-- Highlight Card (Mesh Gradient) -->
  <rect x="85" y="80" width="50" height="180" rx="8" fill="url(#meshGradient)" filter="url(#shadow)" />

  <!-- Highlight Card Border/Accent -->
  <rect x="145" y="100" width="40" height="150" rx="8" fill="#EFF6FF" stroke="#3B82F6" stroke-width="2" />
  
  <!-- Card (Front Right) -->
  <rect x="230" y="70" width="45" height="140" rx="8" fill="#F8FAFC" stroke="#E2E8F0" />

  <!-- Floating Icons -->
  <circle cx="50" cy="50" r="24" fill="white" filter="url(#shadow)" />
  <path d="M42 50 H58 M50 42 V58" stroke="#3B82F6" stroke-width="3" stroke-linecap="round"/>

  <circle cx="250" cy="60" r="20" fill="white" filter="url(#shadow)" />
  <path d="M245 55 L250 65 L255 55" stroke="#3B82F6" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>
''';

  // SVG 2: Smart Scan (Scanner Beam)
  static const String smartScan = '''
<svg width="300" height="300" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="beamGradient" x1="0%" y1="0%" x2="0%" y2="100%">
       <stop offset="0%" stop-color="#1E3A8A" stop-opacity="0" />
       <stop offset="50%" stop-color="#3B82F6" stop-opacity="0.4" />
       <stop offset="100%" stop-color="#1E3A8A" stop-opacity="0" />
    </linearGradient>
  </defs>

  <!-- Main Document Card -->
  <rect x="60" y="50" width="180" height="200" rx="24" fill="white" stroke="#F1F5F9" stroke-width="2" />
  
  <!-- Content Placeholders -->
  <rect x="100" y="90" width="100" height="8" rx="4" fill="#E2E8F0" />
  <rect x="100" y="110" width="80" height="8" rx="4" fill="#E2E8F0" />
  <rect x="100" y="130" width="90" height="8" rx="4" fill="#E2E8F0" />

  <!-- Scanner Icon Overlay -->
  <path d="M90 70 H 80 V 80" stroke="#1E3A8A" stroke-width="4" stroke-linecap="round"/>
  <path d="M210 70 H 220 V 80" stroke="#1E3A8A" stroke-width="4" stroke-linecap="round"/>
  <path d="M90 230 H 80 V 220" stroke="#1E3A8A" stroke-width="4" stroke-linecap="round"/>
  <path d="M210 230 H 220 V 220" stroke="#1E3A8A" stroke-width="4" stroke-linecap="round"/>

  <!-- Scanning Beam -->
  <rect x="70" y="110" width="160" height="60" fill="url(#beamGradient)" />

  <!-- Floating Elements -->
  <circle cx="240" cy="80" r="10" fill="#3B82F6" opacity="0.2" />
  <rect x="50" y="200" width="40" height="8" rx="4" fill="#1E3A8A" opacity="0.1" transform="rotate(-15 70 204)" />
</svg>
''';

  // SVG 3: Saved Ideas (Quote Cloud)
  static const String savedIdeas = '''
<svg width="300" height="300" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="meshGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1E3A8A" />
      <stop offset="100%" stop-color="#3B82F6" />
    </linearGradient>
    <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
      <feDropShadow dx="0" dy="15" stdDeviation="15" flood-color="#3B82F6" flood-opacity="0.3" />
    </filter>
  </defs>

  <!-- Background Abstract Shapes -->
  <rect x="40" y="60" width="140" height="160" rx="16" fill="white" stroke="#F1F5F9" transform="rotate(-6 110 140)" opacity="0.5" />

  <!-- Main Feature Card (Mesh Gradient) -->
  <rect x="100" y="100" width="160" height="120" rx="16" fill="url(#meshGradient)" filter="url(#shadow)" />
  
  <!-- Content inside Card -->
  <rect x="120" y="130" width="120" height="6" rx="3" fill="white" fill-opacity="0.4" />
  <rect x="120" y="145" width="100" height="6" rx="3" fill="white" fill-opacity="0.4" />
  <rect x="120" y="160" width="80" height="6" rx="3" fill="white" fill-opacity="0.4" />

  <!-- Quote Mark Tag -->
  <rect x="120" y="85" width="40" height="30" rx="8" fill="white" stroke="#F1F5F9" />
  <path d="M135 105 Q 132 105 132 100 Q 132 95 138 95" stroke="#1E3A8A" stroke-width="3" stroke-linecap="round" fill="none" transform="scale(0.8) translate(30 20)"/>
  
  <!-- Floating Tag -->
  <rect x="50" y="200" width="80" height="25" rx="12" fill="#F8FAFC" stroke="#E2E8F0" transform="rotate(12 90 212)" />
  <text x="65" y="217" font-family="Tajawal, sans-serif" font-size="10" fill="#64748B" transform="rotate(12 90 212)">#فلسفة</text>
</svg>
''';
}
