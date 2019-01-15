publish: add commit push

add:
	git add .

commit:
	git commit -m '$(msg)'

push:
	git push