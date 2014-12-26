I'm developing on OSX and have little experience C libraries
as ruby extensions, so this readme may relflect that.

### Dependencies

These are bindings to native libraries

- [glfw3](https://github.com/nilium/ruby-glfw3)
- [opengl-core](https://github.com/nilium/opengl-core)
- [opengl-aux](https://github.com/nilium/opengl-aux)

The `glfw3` bindings won't even install without the underlying libraries.

`opengl-core` and `opengl-aux` will install with `bundle install`,
but calls will will fail at runtime.
To ensure these dependencies are _actually_ resoled, do the following:
