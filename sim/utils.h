#ifndef UTILS_H
#define UTILS_H

#include <fstream>
#include <stdexcept>

template<class container_t>
container_t read_file(const std::string& filename)
{
    std::ifstream in (filename, std::ios::binary | std::ios::in | std::ios::ate);

    if (!in.is_open ())
        throw std::runtime_error ("unable open");

    in.exceptions (std::ifstream::failbit | std::ifstream::badbit);

    size_t image_size = in.tellg();
    in.seekg(std::ios_base::beg);

    container_t image (image_size);
    in.read(reinterpret_cast<char*> (image.data ()), image_size);

    std::streamsize chars_readed = in.gcount ();
    if (chars_readed == 0 )
        throw std::runtime_error ("unable read image");

    return image;
}

#endif // UTILS_H
