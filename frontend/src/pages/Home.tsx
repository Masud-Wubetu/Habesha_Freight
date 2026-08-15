import SearchCard from '../components/SearchCard';
import StepCard from '../components/StepCard';
import FeatureCard from '../components/FeatureCard';
import RouteCard from '../components/RouteCard';
import DemoCard from '../components/DemoCard';
import Footer from '../components/Footer';

export default function Home() {
  return (
    <div>
      {/* 1. HERO SECTION */}
      <section style={{ 
        backgroundColor: '#0B1F33',
        padding: '4rem 0 6rem 0',
        position: 'relative'
      }}>
        <div className="container">
          <div className="hero-grid" style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: '4rem',
            alignItems: 'center'
          }}>
            {/* Left Column */}
            <div>
              <span className="hero-badge" style={{
                display: 'inline-block',
                backgroundColor: 'rgba(200, 147, 58, 0.15)',
                color: '#C8933A',
                padding: '0.25rem 1rem',
                borderRadius: '2rem',
                fontSize: '0.875rem',
                fontWeight: '500',
                marginBottom: '1.5rem'
              }}>
                Ethiopia's #1 Digital Freight Marketplace
              </span>
              
              <h1 className="hero-title" style={{
                fontFamily: 'Instrument Serif, serif',
                fontSize: '4rem',
                lineHeight: '1.1',
                marginBottom: '1.5rem'
              }}>
                <span style={{ color: '#FFFFFF' }}>Move Your Cargo.<br /></span>
                <span style={{ color: '#C8933A' }}>Find the Right Truck.</span>
              </h1>
              
              <p className="hero-subtitle" style={{
                color: 'rgba(255,255,255,0.8)',
                fontSize: '1.125rem',
                marginBottom: '2rem',
                maxWidth: '90%'
              }}>
                HabeshaFreight helps shippers find suitable trucks and move cargo efficiently across Ethiopia. Connect with trusted carriers and get your goods delivered safely.
              </p>
              
              <div className="hero-buttons" style={{ display: 'flex', gap: '1rem' }}>
                <a href="#search" className="btn-primary" style={{ fontSize: '1.125rem' }}>
                  Find a Truck
                </a>
                <a href="#search" className="btn-secondary" style={{ fontSize: '1.125rem' }}>
                  Post a Shipment
                </a>
              </div>
            </div>

            {/* Right Column - Visual Placeholder */}
            <div className="hero-visual" style={{
              backgroundColor: 'rgba(255,255,255,0.05)',
              borderRadius: '1rem',
              padding: '3rem',
              border: '2px dashed rgba(200, 147, 58, 0.3)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              minHeight: '300px',
              textAlign: 'center'
            }}>
              <div style={{ fontSize: '5rem', marginBottom: '1rem' }}>🚛</div>
              <p style={{ color: 'rgba(255,255,255,0.6)', fontSize: '1.125rem' }}>
                Truck Illustration<br />
                <span style={{ fontSize: '0.875rem', color: 'rgba(255,255,255,0.4)' }}>Coming Soon</span>
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 2. TRUCK SEARCH CARD */}
      <section id="search" className="search-card" style={{ 
        marginTop: '-3rem', 
        marginBottom: '3rem', 
        position: 'relative', 
        zIndex: 10 
      }}>
        <div className="container">
          <SearchCard />
        </div>
      </section>

      {/* 3. HOW HABESHAFREIGHT WORKS */}
      <section className="bg-light section-padding">
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 className="steps-title" style={{
            fontFamily: 'Instrument Serif, serif',
            fontSize: '3rem',
            marginBottom: '0.5rem'
          }}>
            How HabeshaFreight Works
          </h2>
          <p style={{ fontSize: '1.125rem', color: '#4a4a4a', marginBottom: '3rem' }}>
            Four simple steps to move your cargo anywhere in Ethiopia.
          </p>
          
          <div className="steps-grid" style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(4, 1fr)',
            gap: '2rem'
          }}>
            <StepCard number="01" title="Post Your Shipment" />
            <StepCard number="02" title="Receive Bids" />
            <StepCard number="03" title="Accept &amp; Track" />
            <StepCard number="04" title="Delivery Confirmed" />
          </div>
        </div>
      </section>

      {/* 4. FEATURES */}
      <section className="section-padding">
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 className="features-title" style={{
            fontFamily: 'Instrument Serif, serif',
            fontSize: '3rem',
            marginBottom: '3rem'
          }}>
            Everything You Need to Ship
          </h2>
          
          <div className="features-grid" style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '2rem'
          }}>
            <FeatureCard 
              icon="🔍"
              title="Truck Search"
              description="Find the right truck for your cargo from a network of trusted carriers across Ethiopia."
            />
            <FeatureCard 
              icon="🤝"
              title="Bidding &amp; Negotiation"
              description="Receive competitive bids and negotiate rates directly with carriers for the best deal."
            />
            <FeatureCard 
              icon="📦"
              title="Post a Shipment"
              description="Post your shipment details and let carriers come to you with their best offers."
            />
            <FeatureCard 
              icon="🔒"
              title="Secure Escrow"
              description="Your payment is held securely until delivery is confirmed, protecting both parties."
            />
            <FeatureCard 
              icon="📍"
              title="Live Tracking"
              description="Track your shipment in real-time with GPS tracking and estimated delivery times."
            />
            <FeatureCard 
              icon="💬"
              title="Direct Chat"
              description="Communicate directly with carriers through our built-in messaging system."
            />
          </div>
        </div>
      </section>

      {/* 5. KEY ETHIOPIAN CORRIDORS */}
      <section className="bg-navy section-padding">
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 className="routes-title" style={{
            fontFamily: 'Instrument Serif, serif',
            fontSize: '3rem',
            color: '#FFFFFF',
            marginBottom: '3rem'
          }}>
            Key Ethiopian Corridors
          </h2>
          
          <div className="routes-grid" style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '1.5rem'
          }}>
            <RouteCard from="Addis Ababa" to="Adama" />
            <RouteCard from="Adama" to="Hawassa" />
            <RouteCard from="Addis Ababa" to="Dire Dawa" />
            <RouteCard from="Addis Ababa" to="Bahir Dar" />
            <RouteCard from="Addis Ababa" to="Mekelle" />
            <RouteCard from="Hawassa" to="Jimma" />
          </div>
        </div>
      </section>

      {/* 6. TRY THE DEMO */}
      <section className="bg-light section-padding">
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 className="demo-title" style={{
            fontFamily: 'Instrument Serif, serif',
            fontSize: '3rem',
            marginBottom: '3rem'
          }}>
            Try the Demo
          </h2>
          
          <div className="demo-grid" style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '2rem'
          }}>
            <DemoCard 
              title="Shipper Dashboard"
              description="Post &amp; track shipments"
              route="/dashboard"
            />
            <DemoCard 
              title="Driver Dashboard"
              description="Find loads &amp; manage trips"
              route="/fleet"
            />
            <DemoCard 
              title="Admin Dashboard"
              description="Manage the platform"
              route="/shipments"
            />
          </div>
        </div>
      </section>

      {/* 7. FINAL CTA */}
      <section className="bg-gold section-padding">
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 className="cta-title" style={{
            fontFamily: 'Instrument Serif, serif',
            fontSize: '3rem',
            color: '#070F19',
            marginBottom: '2rem'
          }}>
            Ready to Ship Smarter?
          </h2>
          
          <div className="cta-buttons" style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <a href="/register" style={{
              display: 'inline-block',
              backgroundColor: '#070F19',
              color: '#FFFFFF',
              padding: '0.75rem 2rem',
              borderRadius: '0.5rem',
              fontWeight: '500',
              fontFamily: 'DM Sans, sans-serif',
              transition: 'all 0.2s',
              textDecoration: 'none'
            }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#0B1F33'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#070F19'}
            >
              Register as Shipper
            </a>
            <a href="/register" style={{
              display: 'inline-block',
              backgroundColor: '#FFFFFF',
              color: '#070F19',
              padding: '0.75rem 2rem',
              borderRadius: '0.5rem',
              fontWeight: '500',
              fontFamily: 'DM Sans, sans-serif',
              transition: 'all 0.2s',
              textDecoration: 'none'
            }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#F5F7FA'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#FFFFFF'}
            >
              Register as Driver
            </a>
          </div>
        </div>
      </section>

      {/* 8. FOOTER */}
      <Footer />
    </div>
  );
}