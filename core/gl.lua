local ffi = require("ffi")

ffi.cdef[[
    typedef unsigned int GLenum;
    typedef unsigned char GLboolean;
    typedef unsigned int GLbitfield;
    typedef void GLvoid;
    typedef char GLchar;
    typedef short GLshort;
    typedef int GLint;
    typedef unsigned char GLubyte;
    typedef unsigned short GLushort;
    typedef unsigned int GLuint;
    typedef int GLsizei;
    typedef float GLfloat;
    typedef double GLclampd;
    typedef double GLdouble;
    typedef float GLclampf;
    typedef ptrdiff_t GLsizeiptr;
    typedef ptrdiff_t GLintptr;

    void glClear(GLbitfield mask);
    void glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
    void glEnable(GLenum cap);
    void glDisable(GLenum cap);
    void glDepthFunc(GLenum func);
    void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    void glPixelStorei(GLenum pname, GLint param);

    GLuint glCreateShader(GLenum type);
    void glShaderSource(GLuint shader, GLsizei count, const GLchar* const* string, const GLint* length);
    void glCompileShader(GLuint shader);
    void glGetShaderiv(GLuint shader, GLenum pname, GLint* params);
    void glGetShaderInfoLog(GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
    void glDeleteShader(GLuint shader);

    GLuint glCreateProgram(void);
    void glAttachShader(GLuint program, GLuint shader);
    void glLinkProgram(GLuint program);
    void glGetProgramiv(GLuint program, GLenum pname, GLint* params);
    void glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
    void glUseProgram(GLuint program);
    void glDeleteProgram(GLuint program);

    void glGenBuffers(GLsizei n, GLuint* buffers);
    void glBindBuffer(GLenum target, GLuint buffer);
    void glBufferData(GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
    void glGenVertexArrays(GLsizei n, GLuint* arrays);
    void glBindVertexArray(GLuint array);
    void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* pointer);
    void glEnableVertexAttribArray(GLuint index);

    void glDrawArrays(GLenum mode, GLint first, GLsizei count);
    void glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
    void glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices, GLsizei instancecount);
    void glVertexAttribDivisor(GLuint index, GLuint divisor);

    GLint glGetUniformLocation(GLuint program, const GLchar* name);
    void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
    void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
    void glUniform2f(GLint location, GLfloat v0, GLfloat v1);
    void glUniform1f(GLint location, GLfloat v0);
    void glUniform1i(GLint location, GLint v0);
    void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);

    void glGenTextures(GLsizei n, GLuint* textures);
    void glBindTexture(GLenum target, GLuint texture);
    void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* data);
    void glTexParameteri(GLenum target, GLenum pname, GLint param);
    void glGenerateMipmap(GLenum target);

    void glDepthMask(GLboolean flag);
    void glCullFace(GLenum mode);
    void glFrontFace(GLenum mode);
    void glBlendFunc(GLenum sfactor, GLenum dfactor);
    void glActiveTexture(GLenum texture);
    
    void glDeleteTextures(GLsizei n, const GLuint* textures);
    void glDeleteBuffers(GLsizei n, const GLuint* buffers);
    void glDeleteVertexArrays(GLsizei n, const GLuint* arrays);
]]

local libgl = ffi.load("GL")
local gl = setmetatable({}, {
    __index = function(t, key)
        return libgl[key]
    end
})

gl.COLOR_BUFFER_BIT = 0x00004000
gl.DEPTH_BUFFER_BIT = 0x00000100
gl.TRIANGLES = 0x0004
gl.STATIC_DRAW = 0x88E4
gl.STREAM_DRAW = 0x88E0
gl.TRIANGLE_FAN = 0x0006
gl.ARRAY_BUFFER = 0x8892
gl.ELEMENT_ARRAY_BUFFER = 0x8893
gl.FLOAT = 0x1406
gl.VERTEX_SHADER = 0x8B31
gl.FRAGMENT_SHADER = 0x8B30
gl.DEPTH_TEST = 0x0B71
gl.LEQUAL = 0x0203

gl.TEXTURE_CUBE_MAP = 0x8513
gl.TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515
gl.TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516
gl.TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517
gl.TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518
gl.TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519
gl.TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A
gl.TEXTURE_MIN_FILTER = 0x2800
gl.TEXTURE_MAG_FILTER = 0x2801
gl.TEXTURE_WRAP_S = 0x2802
gl.TEXTURE_WRAP_T = 0x2803
gl.TEXTURE_WRAP_R = 0x8072
gl.CLAMP_TO_EDGE = 0x812F
gl.LINEAR = 0x2601

gl.CULL_FACE = 0x0B44
gl.BACK = 0x0405
gl.FRONT = 0x0404
gl.CCW = 0x0901
gl.CW = 0x0900

gl.BLEND = 0x0BE2
gl.SRC_ALPHA = 0x0302
gl.ONE_MINUS_SRC_ALPHA = 0x0303
gl.UNPACK_ALIGNMENT = 0x0CF5

gl.UNSIGNED_INT = 0x1405
gl.TRIANGLE_STRIP = 0x0005
gl.TRIANGLE_FAN = 0x0006

gl.RGBA = 0x1908
gl.RGB = 0x1907
gl.RED = 0x1903
gl.UNSIGNED_BYTE = 0x1401

gl.TEXTURE_2D = 0x0DE1
gl.TEXTURE0 = 0x84C0

return gl
