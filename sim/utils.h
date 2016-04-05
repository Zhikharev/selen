#ifndef UTILS_H
#define UTILS_H

#include <fstream>
#include <stdexcept>
#include <limits>
#include <iomanip>

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

class Formatter
{
public:
    Formatter()
    {
    }
    Formatter(Formatter&&) = default;

    Formatter(const Formatter&) = delete;
    Formatter& operator= (const Formatter&) = delete;

    template <typename T>
    Formatter& operator << (const T& value)
    {
        stream << value;
        return *this;
    }

    operator std::string () const
    {
        return stream.str();
    }

private:
    std::ostringstream stream;
};

template <typename T>
struct Hex
{
    static constexpr int Width = (std::numeric_limits<T>::digits + 1) / 4;

    const T& value;
    const int width;

    Hex(const T& value, int width = Width) :
        value(value), width(width)
    {}

    void write(std::ostream& stream) const
    {
        if(std::numeric_limits<T>::radix != 2)
        {
            stream << value;
            return;
        }

        std::ios_base::fmtflags flags =
                stream.setf(std::ios_base::hex, std::ios_base::basefield);
        char fill = stream.fill('0');

        stream << std::noshowbase << std::right
               << "0x" << std::setw(width) << value;

        stream.fill(fill);
        stream.setf(flags, std::ios_base::basefield);
    }
};

template <typename T>
inline Hex<T> hex(const T& value, int width = Hex<T>::Width)
{
    return Hex<T>(value, width);
}

template <typename T>
inline std::ostream& operator << (std::ostream& stream, const Hex<T>& value)
{
    value.write(stream);
    return stream;
}

#endif // UTILS_H
