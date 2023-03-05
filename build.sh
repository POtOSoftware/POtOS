if test "`whoami`" != "root" ; then
	echo "Hey you smelly idiot, you need to be root to run this"
	exit
fi

if [ ! -e potos.flp ]
then
	echo "> Creating new floppy image..."
	mkdosfs -C potos.flp 1440 || exit
fi

echo '> Assembling bootloader...'

nasm -f bin -o src/bootload.bin src/bootload.asm || exit

echo '>> Assembling kernel...'

cd src
nasm -f bin -o kernel.bin kernel.asm || exit
cd ..

echo '>>> Writing bootloader to disk image...'

dd status=noxfer conv=notrunc if=src/bootload.bin of=potos.flp || exit

echo '>>>> Writing Kernel to disk image...'

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat potos.flp tmp-loop && cp src/kernel.bin tmp-loop/

sleep 0.2

echo '>>>>> Unmounting loopback floppy...'

umount tmp-loop || exit

rm -rf tmp-loop

echo "<<< I can't believe it, it actually worked"
