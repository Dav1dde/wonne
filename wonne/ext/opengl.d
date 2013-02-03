module wonne.ext.opengl;

version(glamour) {

private {
    import wonne.webview : Webview;
    
    import glamour.gl;
    import glamour.shader : Shader;
    import glamour.vbo : Buffer;
    import glamour.vao : VAO;
    import glamour.texture : Texture2D;
}


enum DEFAULT_SHADER = "
vertex:
    in vec2 texcoord;
    in vec2 position;

    out vec2 v_texcoord;

    void main()
    {
        v_texcoord = texcoord;
        gl_Position = vec4(position, 0.0, 1.0);
    };


fragment:
    in vec2 v_texcoord;

    out vec4 outputColor;

    uniform sampler2D browser;

    void main()
    {
        outputColor = texture2D(browser, v_texcoord);
    }";

enum float[] VERTEX_DATA = [
    1.0f, -1.0f,
    1, 1,
    1.0f, 1.0f,
    1, 0,
    -1.0f, -1.0f,
    0, 1,
    -1.0f, 1.0f,
    0, 0,
    -1.0f, -1.0f,
    0, 1,
    1.0f, 1.0f,
    1, 0,
];

class WebviewRenderer {
    protected Webview webview;    

    protected Shader shader;
    protected Buffer vbo;
    protected VAO vao;
    Texture2D texture;
    
    this(Webview webview, string shader_source=DEFAULT_SHADER) {
        this.webview = webview;

        shader = new Shader("WebviewRenderer", shader_source);

        vao = new VAO();
        vbo = new Buffer();
        
        vao.bind();
        vbo.bind();

        vbo.set_data(VERTEX_DATA);

        GLuint position = shader.get_attrib_location("position");
        GLuint texcoord = shader.get_attrib_location("texcoord");

        vbo.bind(position, GL_FLOAT, 2,    0,              4*float.sizeof);
        vbo.bind(texcoord, GL_FLOAT, 2,    2*float.sizeof, 4*float.sizeof);

        vao.unbind();
        
        texture = new Texture2D();
    }

    void display() {
        shader.bind();

        vao.bind();

        shader.uniform1i("browser", 0);

        if(webview.is_dirty()) {
            update_texture();
        }

        texture.bind_and_activate();

        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    void update_texture() {
        auto render_buffer = webview.render();

        if(render_buffer !is null) {
            with(render_buffer) {
                texture.set_data(buffer, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE);
            }
        }
    }

    void remove() {
        vao.remove();
        vbo.remove();
        texture.remove();
        shader.remove();
    }
}


} // end version(glamour) {