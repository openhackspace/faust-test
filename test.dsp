
// Kommentar
declare name       "mynewplug";
declare copyright  "(c) Hans Höglund 2012";

util = environment {
    filter  = library("filter.lib");
    music   = library("music.lib");
    math    = library("math.lib");
};


smooth(c)       = *(1-c) : +~*(c);

integrate(f)        =   +(f) ~ _;
integrateW(f,g)     =   (+(f) : g) ~ _;

samples     =   integrate(1)-1;           // 0,1,2,3,...
/*samples     = 1 : xloop(+);*/
time        =   float(samples) / float(util.math.SR);



testOsc
    = select2(checkbox("Use table"),
        sin1(freq),
        sin2(freq)
    )
    : *(vol) : meter
    with {
        freqA   =   fmod(time*800,800) + 40;
        freqV   =   hslider("freq [unit:Hz]", 0, 40, 4000, 1);
        freq    =   select2(checkbox("Auto freq"), freqV, freqA);

        vol     =   hslider("volume [unit:dB]", 0, -96, 0, 0.1) : util.music.db2linear : smooth(0.999) ;
        meter   =   hbargraph("Output",-1,1);

        rate    =   float(util.math.SR);
        pi      =   util.math.PI;
        tau     =   2.0*pi;

        // Stateful ramp
        xramp(f) = integrateW( f : /(rate), \(x).(fmod(x,1)) )
        ;
        // Pure ramp FIXME
        ramp(f)  = samples : *(int(f)) : %(int(rate)) : float : /(rate)
        ;

        tableOsc(g,f) = rdtable(size,table,phase)
            with {
                size  = 1 << 16;
                phase = xramp(f) : *(size) : int;
                table = float(samples)/size : g;
            }
        ;


        sin1(f) = xramp(f) :     * (tau) : sin
        ;
        sin2(f) = f : tableOsc ( *(tau) : sin )
        ;
        saw1(f) = xramp(f) :     * (2) : -(1)
        ;
        saw2(f) = f : tableOsc ( *(2) : -(1) )
        ;
        sq1(f)  = xramp(f) :     \(g).(select2(g < 0.5, -1, 1))
        ;
        sq2(f)  = f : tableOsc ( \(g).(select2(g < 0.5, -1, 1)) )
        ;
        tri1(f) = saw1(f) : abs : *(2) : -(1)
        ;
        tri2(f) = saw2(f) : abs : *(2) : -(1)
        ;
    }
    ;        

process 
    = testOsc
    ;