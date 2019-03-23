module Processing

export @sketch

using SimpleDirectMediaLayer
const SDL = SimpleDirectMediaLayer

mutable struct PApp
    window::Ptr{SDL.Window}
    windowSize::Tuple{Int64,Int64}
    windowTitle::String
    renderer::Ptr{SDL.Renderer}
    surface::Ptr{SDL.Surface}
    running::Bool
end

macro sketch(program::Expr)
    if program.head != :block
        println("A sketch needs to be a block with the syntax:\n@sketch begin\n\t...\nend")
        return
    end

    Pprogram = begin
        function PExcecute()
            Papp = PApp(Ptr{SDL.Window}(0), (800, 600), "Processing.jl", Ptr{SDL.Renderer}(0), Ptr{SDL.Surface}(0), true)
            function size(x::Integer, y::Integer, renderer=0)
                PApp.windowSize = (x,y)
            end

            function stroke(r, g, b)
                SDL.SetRenderDrawColor(map(Int32,(r,g,b))...)
            end

            function point(x, y, z=0)
                SDL.RenderDrawPoint(Papp.renderer, Int32(x), Int32(y))
            end

            function draw()

            end

            eval(program)

            SDL.init()
            windowLocation = Int32(SDL.WINDOWPOS_UNDEFINED_MASK)
            Papp.window = SDL.CreateWindow(Papp.windowTitle,
                                           windowLocation,
                                           windowLocation,
                                           map(Int32, Papp.windowSize)...,
                                           SDL.WINDOW_SHOWN)

            SDL.SetWindowResizable(Papp.window, true)

            Papp.renderer = SDL.CreateRenderer(Papp.window, Int32(-1), SDL.RENDERER_ACCELERATED)

            setup()

            try
                while Papp.running
                    SDL.PumpEvents()
                    SDL.SetRenderDrawColor(Papp.renderer, 0, 0, 0, 255)
                    SDL.RenderClear(Papp.renderer)
                    x,y = Int[1], Int[1]
                    SDL.GetMouseState(pointer(x), pointer(y))
                    mouseX, mouseY = x, y
                    draw()

                    SDL.SetRenderDrawColor(Papp.renderer, 20, 50, 105, 255)
                    SDL.RenderDrawLine(Papp.renderer,0,0,800,600)

                    rect = SDL.Rect(1,1,200,200)
                    SDL.RenderFillRect(Papp.renderer, pointer_from_objref(rect) )

                    SDL.RenderPresent(Papp.renderer)
                    sleep(0.01)
                end
            catch InterruptException
                println("Processing sketch terminated.")
            end
            SDL.DestroyRenderer(Papp.renderer)
            SDL.DestroyWindow(Papp.window)
            SDL.Quit()
        end
        PExcecute()
    end
    return :($Pprogram)
end

import SimpleDirectMediaLayer.LoadBMP

import Base.unsafe_convert

function reference_stuff()

    SDL.GL_SetAttribute(SDL.GL_MULTISAMPLEBUFFERS, 16)
    SDL.GL_SetAttribute(SDL.GL_MULTISAMPLESAMPLES, 16)

    SDL.init()

    win = SDL.CreateWindow("Hello World!", Int32(100), Int32(100), Int32(800), Int32(600),
                            UInt32(SDL.WINDOW_SHOWN))
    SDL.SetWindowResizable(win,true)

    renderer = SDL.CreateRenderer(win, Int32(-1),
                                   UInt32(SDL.RENDERER_ACCELERATED | SDL.RENDERER_PRESENTVSYNC))

    unsafe_convert(::Type{Ptr{SDL.RWops}}, s::String) = SDL.RWFromFile(s, "rb")

    LoadBMP(src::String) = SDL.LoadBMP_RW(src,Int32(1))

    bkg = SDL.Color(100, 200, 200, 255)

#Create text
    font = TTF_OpenFont(joinpath(@__DIR__,"/home/arnaldur/.julia/packages/SimpleDirectMediaLayer/CVoX4/assets/fonts/FiraCode/ttf/FiraCode-Regular.ttf"), 14)
#txt = "@BinDeps.install Dict([ (:glib, :libglib) ])"
    txt = "hi"
    text = TTF_RenderText_Blended(font, txt, SDL.Color(20,20,20,255))
    tex = SDL.CreateTextureFromSurface(renderer,text)

    fx,fy = Int[1], Int[1]
    TTF_SizeText(font, txt, pointer(fx), pointer(fy))
    fx,fy = fx[1],fy[1]

    img = SDL.LoadBMP("/home/arnaldur/Pictures/tmp.png")
    tex = SDL.CreateTextureFromSurface(renderer, img)
    SDL.FreeSurface(img)

    for i = 1:200
        x,y = Int[1], Int[1]
        SDL.PumpEvents()
        SDL.GetMouseState(pointer(x), pointer(y))

#Set render color to red(background will be rendered in this color)
        SDL.SetRenderDrawColor(renderer, 100, 200, 200, 255)
        SDL.RenderClear(renderer)

        SDL.SetRenderDrawColor(renderer, 20, 50, 105, 255)
        SDL.RenderDrawLine(renderer,0,0,800,600)

        rect = SDL.Rect(1,1,200,200)
        SDL.RenderFillRect(renderer, pointer_from_objref(rect) )
        SDL.RenderCopy(renderer, tex, C_NULL, pointer_from_objref(SDL.Rect(x[1],y[1],fx,fy)))

        SDL.RenderPresent(renderer)
        sleep(0.01)
    end
    SDL.Quit()

end
greet() = print("Hello World!")

end # module
